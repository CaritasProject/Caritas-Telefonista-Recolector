from db import get_connection

conn = get_connection()
cursor = conn.cursor()

cursor.execute("SELECT 1")
result = cursor.fetchone()

print(result)

cursor.close()
conn.close()
