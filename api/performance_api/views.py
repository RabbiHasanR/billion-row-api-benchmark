from django.db import connection
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from utils.pg_functions import call_pg_function_json
import subprocess
import pandas as pd


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
    
    







class LoadTestView(APIView):
    def post(self, request):
        try:
            # Retrieve parameters from request
            users = request.data.get("users", 1000)  # Default: 1000 users
            spawn_rate = request.data.get("spawn_rate", 100)  # Default: 100 per second
            api_url = request.data.get("api_url")  # No default, must be provided

            if not api_url:
                return Response({
                    "success": False,
                    "message": "API URL is required."
                }, status=status.HTTP_400_BAD_REQUEST)

            # Run Locust for API load testing (5s duration)
            locust_cmd = [
                "locust",
                "-f", "utils/load_test.py",
                "--users", str(users),
                "--spawn-rate", str(spawn_rate),
                "--host", api_url,
                "--headless",
                "--csv", "load_test_results",
                "-t", "1m"
            ]
            subprocess.run(locust_cmd, check=True)

            # Read Locust metrics from the CSV results
            locust_stats_file = "load_test_results_stats.csv"
            locust_json = []
            try:
                df = pd.read_csv(locust_stats_file)

                # Convert NaN values to 0 or None
                df.fillna(0, inplace=True)

                for _, row in df.iterrows():
                    locust_json.append({
                        "request_type": row["Type"],
                        "request_name": row["Name"],
                        "request_count": int(row["Request Count"]),  
                        "failure_count": int(row["Failure Count"]),
                        "median_response_time_ms": float(row["Median Response Time"]),
                        "average_response_time_ms": float(row["Average Response Time"]),
                        "min_response_time_ms": float(row["Min Response Time"]),
                        "max_response_time_ms": float(row["Max Response Time"]),
                        "requests_per_second": float(row["Requests/s"])
                    })

            except Exception as e:
                locust_json = {"error": f"Failed to process Locust CSV: {str(e)}"}

            return Response({
                "success": True,
                "message": "Load test completed.",
                "locust_results": locust_json
            }, status=status.HTTP_200_OK)

        except Exception as e:
            return Response({
                "success": False,
                "message": f"Load test failed: {str(e)}"
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)