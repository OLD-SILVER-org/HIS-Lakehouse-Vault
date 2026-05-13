import os

# Database Metadata của Superset (Dùng chung Postgres với Warehouse)
SQLALCHEMY_DATABASE_URI = 'postgresql://dwh_admin:dwh_admin%40123@postgres-warehouse:5432/superset_metadata'

SECRET_KEY = 'your-secret-key-here-very-secret'
WTF_CSRF_ENABLED = False
ENABLE_CORS = True
MAPBOX_API_KEY = ''

# Cho phép nhúng vào iframe (embedded web portal)
# Talisman trong Superset 5.x override X-Frame-Options, phải config đúng ở đây
TALISMAN_ENABLED = True
TALISMAN_CONFIG = {
    "content_security_policy": None,       # Tắt CSP để iframe load được
    "force_https": False,                  # Không redirect sang HTTPS
    "frame_options": "ALLOWALL",           # Cho phép nhúng vào iframe từ mọi nguồn
    "frame_options_allow_from": None,
}
SESSION_COOKIE_SAMESITE = None
SESSION_COOKIE_SECURE = False
SESSION_COOKIE_HTTPONLY = False

FEATURE_FLAGS = {
    "EMBEDDED_SUPERSET": True,
}