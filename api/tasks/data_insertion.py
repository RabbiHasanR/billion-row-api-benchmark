from celery import shared_task
from utils.db import copy_to_db, get_max_id, get_db_connection
from utils.random_data import generate_customers, generate_products, generate_purchases

@shared_task
def insert_customers(total_customers):
    rows = list(generate_customers(total_customers))
    print(f"[insert_customers] Generated {len(rows)} rows")
    copy_to_db('customers', rows, ('name', 'email', 'country', 'created_at'))
    return f"Inserted {len(rows)} customers"

@shared_task
def insert_products(total_products):
    rows = list(generate_products(total_products))
    print(f"[insert_products] Generated {len(rows)} rows")
    copy_to_db('products', rows, ('name', 'category', 'price', 'created_at'))
    return f"Inserted {len(rows)} products"

@shared_task
def insert_purchases(total_purchases):
    rows = list(generate_purchases(total_purchases))
    print(f"[insert_purchases] Generated {len(rows)} rows")
    copy_to_db('purchases', rows, (
        'customer_id', 'product_id', 'quantity', 'total_price',
        'purchase_time', 'region', 'payment_mode', 'status'
    ))
    return f"Inserted {len(rows)} purchases"
