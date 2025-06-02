from django.urls import path
from .views import (
    LatestPurchasesView, 
    AnalyzeLatestPurchasesView
)

urlpatterns = [
    path("purchases/latest/", LatestPurchasesView.as_view(), name="latest-purchases"),
    path("purchases/latest/analyze/", AnalyzeLatestPurchasesView.as_view(), name="analyze-latest-purchases"),
]