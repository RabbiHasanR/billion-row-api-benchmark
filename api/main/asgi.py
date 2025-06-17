"""
ASGI config for main project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/5.2/howto/deployment/asgi/
"""

import os

from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter
import websockets.routing

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "main.settings")

application = ProtocolTypeRouter({
    "http": get_asgi_application(),
    "websocket": URLRouter(websockets.routing.websocket_urlpatterns),
})