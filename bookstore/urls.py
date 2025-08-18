# bookstore/urls.py

from django.contrib import admin
from django.urls import path, include, re_path
from rest_framework.authtoken import views  # Importe a view de token
from django.http import HttpResponse


def home_view(request):
    """View de exemplo para a URL raiz."""
    return HttpResponse("<h1>Bem-vindo a Bookstore</h1>")


urlpatterns = [
    # Adicione a URL raiz que aponta para a view de exemplo
    path("", home_view, name="home"),
    path("admin/", admin.site.urls),
    # URLs para as aplicações order e product
    re_path("bookstore/(?P<version>(v1|v2))/", include("order.urls")),
    re_path("bookstore/(?P<version>(v1|v2))/", include("product.urls")),
    # Adicione a URL para a autenticação com token
    path("api-token-auth/", views.obtain_auth_token),
]
