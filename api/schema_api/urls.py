from django.urls import path
from .views import SchemaExecuteView

urlpatterns = [
    path('execute-schema/', SchemaExecuteView.as_view(), name='execute-schema'),
]
