from io import StringIO
import psycopg2
from django.conf import settings
import time

def get_db_connection():
    return psycopg2.connect(
        dbname=settings.DATABASES['default']['NAME'],
        user=settings.DATABASES['default']['USER'],
        password=settings.DATABASES['default']['PASSWORD'],
        host=settings.DATABASES['default']['HOST'],
        port=settings.DATABASES['default']['PORT'],
    )

def copy_to_db(table_name, rows, columns):
    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        buf = StringIO()
        for row in rows:
            processed_row = [str(item) if hasattr(item, 'isoformat') else item for item in row]
            buf.write('\t'.join(map(str, processed_row)) + '\n')
        buf.seek(0)
        cursor.copy_from(buf, table_name, columns=columns)
        conn.commit()
    except Exception as e:
        conn.rollback()  # Roll back on error
        raise Exception(f"Failed to copy data to {table_name}: {str(e)}")
    finally:
        cursor.close()
        conn.close()
    

def get_max_id(table_name):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(f"SELECT COALESCE(MAX(id), 0) FROM {table_name}")
    max_id = cursor.fetchone()[0]
    cursor.close()
    conn.close()
    return max_id
