import psycopg2
from psycopg2 import OperationalError

def create_connection():
    try:
        # Kết nối tới PostgreSQL
        connection = psycopg2.connect(
            user="postgres",
            password="Hongngoc27112004",
            host="127.0.0.1",
            port="5432",
            database="notes_db"
        )
        print("Kết nối tới PostgreSQL thành công")
    except OperationalError as e:
        print(f"Lỗi xảy ra: '{e}'")
    return connection

# Gọi hàm để kiểm tra kết nối
create_connection()