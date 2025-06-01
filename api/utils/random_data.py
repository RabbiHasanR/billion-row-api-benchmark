import random
from faker import Faker
from datetime import datetime, timezone
import uuid
from .db import get_max_id

faker = Faker()

def generate_customers(batch_size):
    timestamp = datetime.now(timezone.utc).strftime('%Y%m%d%H%M%S%f')
    for i in range(batch_size):
        unique_part = f"{timestamp}_{i}_{uuid.uuid4().hex[:6]}"
        yield (
            f"Customer-{unique_part}",
            f"user{unique_part}@example.com",
            faker.country(),
            faker.date_time_this_decade()
        )

def generate_products(batch_size):
    categories = ['Electronics', 'Clothing', 'Books', 'Home', 'Toys']
    timestamp = datetime.now(timezone.utc).strftime('%Y%m%d%H%M%S%f')
    for i in range(batch_size):
        unique_part = f"{timestamp}_{i}_{uuid.uuid4().hex[:6]}"
        yield (
            f"Product-{unique_part}",
            random.choice(categories),
            round(random.uniform(1, 1000), 2),
            faker.date_time_this_decade()
        )

def generate_purchases(batch_size):
    regions = ['North', 'South', 'East', 'West']
    payment_modes = ['Credit Card', 'UPI', 'Cash']
    statuses = ['Completed', 'Pending', 'Failed']
    
    customer_id_max_range = get_max_id('customers')
    product_id_max_range = get_max_id('products')
    for _ in range(batch_size):
        yield (
            random.randint(1, customer_id_max_range),
            random.randint(1, product_id_max_range),
            random.randint(1, 10),
            round(random.uniform(10, 5000), 2),
            faker.date_time_this_decade(),
            random.choice(regions),
            random.choice(payment_modes),
            random.choice(statuses)
        )
