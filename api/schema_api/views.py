import os
from math import ceil
from django.conf import settings
from django.http import JsonResponse
from rest_framework.views import APIView
from rest_framework.response import Response
from django.db import connection
from rest_framework import status
from tasks.data_insertion import insert_customers, insert_products, insert_purchases
from celery import group, chain

class SchemaExecuteView(APIView):
    def post(self, request):
        sql_dir = os.path.join(settings.BASE_DIR, 'psql')

        if not os.path.exists(sql_dir):
            return Response({
                "status": "failed",
                "errors": ["psql directory not found"],
                "data": None,
                "message": "Schema execution aborted"
            }, status=status.HTTP_404_NOT_FOUND)

        sql_files = sorted([f for f in os.listdir(sql_dir) if f.endswith('.sql')])
        if not sql_files:
            return Response({
                "status": "failed",
                "errors": ["No .sql files found in psql directory"],
                "data": None,
                "message": "Schema execution aborted"
            }, status=status.HTTP_404_NOT_FOUND)

        errors = []
        executed_files = []

        try:
            with connection.cursor() as cursor:
                for filename in sql_files:
                    file_path = os.path.join(sql_dir, filename)
                    try:
                        with open(file_path, 'r') as file:
                            sql_content = file.read()
                            cursor.execute(sql_content)
                            executed_files.append(filename)
                    except Exception as file_error:
                        errors.append(f"{filename}: {str(file_error)}")

            if errors:
                return Response({
                    "status": "failed",
                    "errors": errors,
                    "data": executed_files,
                    "message": "Some SQL files failed to execute"
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

            return Response({
                "status": "success",
                "errors": [],
                "data": executed_files,
                "message": "All SQL files executed successfully"
            }, status=status.HTTP_200_OK)

        except Exception as e:
            return Response({
                "status": "failed",
                "errors": [str(e)],
                "data": executed_files,
                "message": "Execution failed due to a database error"
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)






class InsertDataView(APIView):
    def post(self, request):
        try:
            # Parse request parameters
            batch_size = int(request.data.get('batch_size', 100_000))
            total_customers = int(request.data.get('total_customers', 1_000_000))
            total_products = int(request.data.get('total_products', 100_000))
            total_purchases = int(request.data.get('total_purchases', 5_000_000))
            insert_stage = request.data.get('stage', 'all')

            # Prepare customer tasks
            customer_tasks = []
            if insert_stage in ['customers', 'all']:
                num_batches = ceil(total_customers / batch_size)
                customer_tasks = [
                    insert_customers.si(batch_size=batch_size) for _ in range(num_batches)
                ]

            # Prepare product tasks
            product_tasks = []
            if insert_stage in ['products', 'all']:
                num_batches = ceil(total_products / batch_size)
                product_tasks = [
                    insert_products.si(batch_size=batch_size) for _ in range(num_batches)
                ]
            # Prepare purchase tasks
            purchase_tasks = []
            if insert_stage in ['purchases', 'all']:
                num_batches = ceil(total_purchases / batch_size)
                purchase_tasks = [
                    insert_purchases.si(
                        batch_size=batch_size
                    ) for _ in range(num_batches)
                ]

            # Build final task execution order: customers -> products -> purchases
            task_sequence = []
            if customer_tasks:
                task_sequence.append(group(customer_tasks))
            if product_tasks:
                task_sequence.append(group(product_tasks))
            if purchase_tasks:
                task_sequence.append(group(purchase_tasks))

            # Run tasks in sequence using chain
            if task_sequence:
                workflow = chain(*task_sequence).apply_async()
            else:
                workflow = None

            return Response({
                "status": "accepted",
                "message": f"Started inserting data for stages: {insert_stage}",
                "workflow_id": workflow.id if workflow else None
            }, status=status.HTTP_202_ACCEPTED)

        except Exception as e:
            return Response({
                "status": "failed",
                "error": str(e)
            }, status=status.HTTP_400_BAD_REQUEST)