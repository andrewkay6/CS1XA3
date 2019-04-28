from django.urls import path
from . import views

# routed from e/macid/userauthapp/
urlpatterns = [
    path('adduser/', views.add_user , name = 'userauthapp-add_user') ,
    path('loginuser/', views.login_user , name = 'userauthapp-login_user') ,
]
