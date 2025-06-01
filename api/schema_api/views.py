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
            total_customers = int(request.data.get('total_customers', 1_000_000))
            # total_customers = int(request.data.get('total_customers', 1_000))
            total_products = int(request.data.get('total_products', 100_000))
            # total_products = int(request.data.get('total_products', 100))
            total_purchases = int(request.data.get('total_purchases', 5_000_000))
            insert_stage = request.data.get('stage', 'all')

            # logger.info(f"Received data insert request: {insert_stage}, customers={total_customers}, products={total_products}")

            workflow = None

            if insert_stage == 'all':
                # Customers + Products in parallel, then purchases
                parallel_tasks = group(
                    insert_customers.s(total_customers),
                    insert_products.s(total_products)
                )
                workflow = chain(
                    parallel_tasks,
                    insert_purchases.si(total_purchases)
                ).apply_async()

            elif insert_stage == 'customers':
                workflow = insert_customers.s(total_customers).apply_async()

            elif insert_stage == 'products':
                workflow = insert_products.s(total_products).apply_async()

            elif insert_stage == 'purchases':
                workflow = insert_purchases.s(total_purchases).apply_async()

            else:
                return Response({
                    "status": "failed",
                    "message": f"Unknown stage: {insert_stage}"
                }, status=status.HTTP_400_BAD_REQUEST)

            return Response({
                "status": "accepted",
                "message": f"Started inserting data for stage(s): {insert_stage}",
                "workflow_id": workflow.id if workflow else None
            }, status=status.HTTP_202_ACCEPTED)

        except Exception as e:
            # logger.error(f"InsertDataView error: {e}")
            return Response({
                "status": "failed",
                "error": str(e)
            }, status=status.HTTP_400_BAD_REQUEST)