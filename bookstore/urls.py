from django.urls import path, include, re_path
from rest_framework.authtoken.views import obtain_auth_token

# Importa os routers dos apps
from order.urls import router as order_router
from product import admin
from product.urls import router as product_router

urlpatterns = [
    path("admin/", admin.site.urls),
    re_path("bookstore/(?P<version>(v1|v2))/", include(product_router.urls)),
    re_path("bookstore/(?P<version>(v1|v2))/", include(order_router.urls)),
    path("api-token-auth/", obtain_auth_token, name="api_token_auth"),
]
