from django.db import connection
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from utils.pg_functions import call_pg_function_json



class LatestPurchasesView(APIView):
    def get(self, request):
        try:
            limit = int(request.query_params.get("limit", 100))
        except ValueError:
            return Response({
                "success": False,
                "message": "Invalid value for limit"
            }, status=status.HTTP_400_BAD_REQUEST)

        region = request.query_params.get("region")
        params = {
            "limit": limit,
            "region": region or None
        }
        result = call_pg_function_json("latest_purchases", params)
        return Response(result, status=status.HTTP_200_OK if result.get("success") else status.HTTP_400_BAD_REQUEST)
    


class AnalyzeLatestPurchasesView(APIView):
    def get(self, request):
        try:
            limit = int(request.query_params.get("limit", 100))
        except ValueError:
            return Response({
                "success": False,
                "message": "Invalid value for limit"
            }, status=status.HTTP_400_BAD_REQUEST)

        region = request.query_params.get("region")
        params = {
            "limit": limit,
            "region": region or None
        }
        result = call_pg_function_json("analyze_latest_purchases", params)
        return Response(result, status=status.HTTP_200_OK if result.get("success", True) else status.HTTP_400_BAD_REQUEST)
    
    


