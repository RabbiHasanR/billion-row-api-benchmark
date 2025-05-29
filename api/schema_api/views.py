import os
from django.conf import settings
from django.http import JsonResponse
from rest_framework.views import APIView
from django.db import connection

class SchemaExecuteView(APIView):
    def post(self, request):
        sql_dir = os.path.join(settings.BASE_DIR, 'psql')

        if not os.path.exists(sql_dir):
            return JsonResponse({
                "status": "failed",
                "errors": ["psql directory not found"],
                "data": None,
                "message": "Schema execution aborted"
            }, status=404)

        sql_files = sorted([f for f in os.listdir(sql_dir) if f.endswith('.sql')])
        if not sql_files:
            return JsonResponse({
                "status": "failed",
                "errors": ["No .sql files found in psql directory"],
                "data": None,
                "message": "Schema execution aborted"
            }, status=404)

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
                return JsonResponse({
                    "status": "failed",
                    "errors": errors,
                    "data": executed_files,
                    "message": "Some SQL files failed to execute"
                }, status=500)

            return JsonResponse({
                "status": "success",
                "errors": [],
                "data": executed_files,
                "message": "All SQL files executed successfully"
            })

        except Exception as e:
            return JsonResponse({
                "status": "failed",
                "errors": [str(e)],
                "data": executed_files,
                "message": "Execution failed due to a database error"
            }, status=500)
