from django.urls import path
from . import views
urlpatterns = [
    path ("" , views.hell0 , name = "testreq.hello")
]
