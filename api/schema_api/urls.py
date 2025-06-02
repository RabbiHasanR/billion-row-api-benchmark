from django.urls import path
from .views import SchemaExecuteView, InsertDataView, MigratePurchasesView

urlpatterns = [
    path('execute-schema/', SchemaExecuteView.as_view(), name='execute-schema'),
    path('insert-data/', InsertDataView.as_view(), name='insert-data'),
    path('migrate-purchases-partition/', MigratePurchasesView.as_view(), name='migrate_purchases-partition'),
]
