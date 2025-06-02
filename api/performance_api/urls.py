from django.urls import path
from .views import (
    LatestPurchasesView, 
    AnalyzeLatestPurchasesView,
    LoadTestView
)

urlpatterns = [
    path("purchases/latest/", LatestPurchasesView.as_view(), name="latest-purchases"),
    path("purchases/latest/analyze/", AnalyzeLatestPurchasesView.as_view(), name="analyze-latest-purchases"),
    path("load-test/", LoadTestView.as_view(), name="load-test"),
]