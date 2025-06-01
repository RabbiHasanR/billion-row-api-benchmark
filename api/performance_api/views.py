from django.db import connection
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status


def run_raw_query(sql, params):
    with connection.cursor() as cursor:
        cursor.execute(sql, params)
        desc = cursor.description
        columns = [col[0] for col in desc] if desc else []
        return [dict(zip(columns, row)) for row in cursor.fetchall()]


class PurchaseSearchView(APIView):
    def get(self, request):
        params = {
            "customer_id": request.GET.get("customer_id"),
            "product_id": request.GET.get("product_id"),
            "status": request.GET.get("status"),
            "region": request.GET.get("region"),
            "payment_mode": request.GET.get("payment_mode"),
            "start_date": request.GET.get("start_date"),
            "end_date": request.GET.get("end_date"),
            "min_total_price": request.GET.get("min_total_price"),
        }
        sql = open("performance_api/raw_queries.sql").read().split("/* name: ")
        query = next(q.split("*/")[1].strip() for q in sql if q.startswith("search_purchases"))
        results = run_raw_query(query, params)
        return Response(results)


class SalesTrendView(APIView):
    def get(self, request):
        params = {
            "interval": request.GET.get("interval", "day"),
            "start_date": request.GET.get("start_date"),
            "end_date": request.GET.get("end_date"),
        }
        sql = open("performance_api/raw_queries.sql").read().split("/* name: ")
        query = next(q.split("*/")[1].strip() for q in sql if q.startswith("sales_trend"))
        results = run_raw_query(query, params)
        return Response(results)


class TopCustomersView(APIView):
    def get(self, request):
        params = {
            "start_date": request.GET.get("start_date"),
            "end_date": request.GET.get("end_date"),
            "region": request.GET.get("region"),
            "limit": int(request.GET.get("limit", 10)),
        }
        sql = open("performance_api/raw_queries.sql").read().split("/* name: ")
        query = next(q.split("*/")[1].strip() for q in sql if q.startswith("top_customers"))
        results = run_raw_query(query, params)
        return Response(results)


class TopSellingProductsView(APIView):
    def get(self, request):
        params = {
            "start_date": request.GET.get("start_date"),
            "end_date": request.GET.get("end_date"),
            "limit": int(request.GET.get("limit", 10)),
        }
        sql = open("performance_api/raw_queries.sql").read().split("/* name: ")
        query = next(q.split("*/")[1].strip() for q in sql if q.startswith("top_selling_products"))
        results = run_raw_query(query, params)
        return Response(results)