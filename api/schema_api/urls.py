from django.urls import path
from .views import SchemaExecuteView, InsertDataView

urlpatterns = [
    path('execute-schema/', SchemaExecuteView.as_view(), name='execute-schema'),
    path('insert-data/', InsertDataView.as_view(), name='insert-data'),
]
