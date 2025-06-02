import json
from django.db import connection

def call_pg_function_json(func_name, params):
    placeholders = ", ".join([f"%({k})s" for k in params])
    sql = f"SELECT {func_name}({placeholders});"
    with connection.cursor() as cursor:
        try:
            cursor.execute(sql, params)
            row = cursor.fetchone()
            if row and row[0]:
                result = row[0]
                if isinstance(result, dict):
                    return result
                return json.loads(result)
            return {"success": False, "message": "No response from function."}
        except Exception as e:
            return {
                "success": False,
                "message": str(e)
            }