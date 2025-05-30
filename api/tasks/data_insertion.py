from celery_config.celery import app
from utils.db import copy_to_db, get_max_id
from utils.random_data import generate_customers, generate_products, generate_purchases

@app.task
def insert_customers(batch_size=100000):
    rows = list(generate_customers(batch_size))
    copy_to_db('customers', rows, ('name', 'email', 'country', 'created_at'))
    return f"Inserted {batch_size} customers"

@app.task
def insert_products(batch_size=100000):
    rows = list(generate_products(batch_size))
    copy_to_db('products', rows, ('name', 'category', 'price', 'created_at'))
    return f"Inserted {batch_size} products"

@app.task
def insert_purchases(batch_size=100_000):
    customer_id_max = get_max_id('customers')
    product_id_max = get_max_id('products')

    rows = list(generate_purchases(batch_size, customer_id_max, product_id_max))
    copy_to_db('purchases', rows, (
        'customer_id', 'product_id', 'quantity', 'total_price',
        'purchase_time', 'region', 'payment_mode', 'status'
    ))
    return f"Inserted {batch_size} purchases referencing customer_id <= {customer_id_max}, product_id <= {product_id_max}"
