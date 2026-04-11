import os

# Database Metadata của Superset (Dùng chung Postgres với Warehouse)
SQLALCHEMY_DATABASE_URI = 'postgresql://dwh_admin:dwh_admin%40123@postgres-warehouse:5432/superset_metadata'

SECRET_KEY = 'your-secret-key-here-very-secret'
WTF_CSRF_ENABLED = False
ENABLE_CORS = True
MAPBOX_API_KEY = ''
