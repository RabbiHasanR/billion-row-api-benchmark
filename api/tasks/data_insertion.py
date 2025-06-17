from celery import shared_task
from utils.db import copy_to_db, get_max_id, get_db_connection
from utils.random_data import generate_customers, generate_products, generate_purchases
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync


def send_websocket_update(message):
    """Function to send WebSocket updates via Django Channels."""
    channel_layer = get_channel_layer()
    async_to_sync(channel_layer.group_send)(
        "task_updates",
        {"type": "send_task_update", "status": "completed", "message": message}
    )

@shared_task
def insert_customers(total_customers, notify=True):
    rows = list(generate_customers(total_customers))
    print(f"[insert_customers] Generated {len(rows)} rows")
    copy_to_db('customers', rows, ('name', 'email', 'country', 'created_at'))
    if notify:
        send_websocket_update(f"{total_customers} customers inserted")
    return f"Inserted {len(rows)} customers"

@shared_task
def insert_products(total_products, notify=True):
    rows = list(generate_products(total_products))
    print(f"[insert_products] Generated {len(rows)} rows")
    copy_to_db('products', rows, ('name', 'category', 'price', 'created_at'))
    if notify:
        send_websocket_update(f"{total_products} products inserted")
    return f"Inserted {len(rows)} products"

@shared_task
def insert_purchases(total_purchases, notify=True):
    rows = list(generate_purchases(total_purchases))
    print(f"[insert_purchases] Generated {len(rows)} rows")
    copy_to_db('purchases', rows, (
        'customer_id', 'product_id', 'quantity', 'total_price',
        'purchase_time', 'region', 'payment_mode', 'status'
    ))
    if notify:
        send_websocket_update(f"{total_purchases} purchases inserted")
    return f"Inserted {len(rows)} purchases"



@shared_task
def send_final_notification():
    """Send a WebSocket update when all data insertions are complete."""
    channel_layer = get_channel_layer()
    async_to_sync(channel_layer.group_send)(
        "task_updates",
        {"type": "send_task_update", "status": "completed", "message": "All insert stages completed!"}
    )
