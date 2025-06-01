from django.urls import path
from .views import (
    PurchaseSearchView,
    SalesTrendView,
    TopCustomersView,
    TopSellingProductsView,
)

urlpatterns = [
    path("purchases/search/", PurchaseSearchView.as_view()),
    path("analytics/sales-trend/", SalesTrendView.as_view()),
    path("purchases/top-customers/", TopCustomersView.as_view()),
    path("products/top-selling/", TopSellingProductsView.as_view()),
]