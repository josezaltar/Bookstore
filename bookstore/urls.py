"""bookstore URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""

import os
from django.contrib import admin
from django.urls import include, path, re_path
from rest_framework.authtoken.views import obtain_auth_token

urlpatterns = [
    path("admin/", admin.site.urls),
    re_path("bookstore/(?P<version>(v1|v2))/order/", include("order.urls")),
    re_path("bookstore/(?P<version>(v1|v2))/product/", include("product.urls")),
    path("api-token-auth/", obtain_auth_token, name="api_token_auth"),
]

# Condiciona a inclusão do debug_toolbar ao ambiente de desenvolvimento
if int(os.environ.get("DEBUG_TOOLBAR_ENABLED", 0)):
    import debug_toolbar

    urlpatterns += [
        path("__debug__/", include(debug_toolbar.urls)),
    ]
