# Hướng dẫn Setup Spark Local kết nối Docker Services

Để bạn có thể viết code và chạy thử Spark ngay trên máy (Local) mà vẫn lấy được Data từ Hive/MinIO trong Docker, hãy làm theo các bước sau:

## 1. Cài đặt Thư viện Python (Local)
Bạn cần cài đặt `pyspark` vào môi trường Python hiện tại của máy:
```bash
pip install pyspark==3.5.6
```
*(Nên dùng version 3.5.6 để đồng nhất với version trong Docker của bạn)*

## 2. Map Host (Cực kỳ quan trọng)
Do code trong Spark cần gọi các service bằng tên (vd: `hive-metastore`), bạn cần map các tên này về `127.0.0.1` ở máy Windows.

1. Mở Notepad bằng quyền **Administrator**.
2. Mở file: `C:\Windows\System32\drivers\etc\hosts`.
3. Thêm các dòng sau vào cuối file:
   ```text
   127.0.0.1 hive-metastore
   127.0.0.1 minio
   127.0.0.1 postgres-hive
   ```

## 2. Thư viện JARs cho Local
Bạn cần download các file JAR này và để vào thư mục `jars` trong thư mục cài Spark local của bạn (hoặc add vào `ClassPath` của IDE):
- `hadoop-aws-3.3.6.jar`
- `aws-java-sdk-bundle-1.12.785.jar`
- `postgresql-42.7.9.jar`

> Các file này bạn có thể copy từ `infrastructure/2_lake/jars/` nếu đã có.

## 3. Cách chuyển đổi (Switch)
Mình sẽ cung cấp file `spark_utils.py`. Khi bạn dùng file này:
- **Chạy Local**: Nó sẽ dùng `master("local[*]")`.
- **Chạy Docker**: Bạn chỉ cần thêm biến môi trường `SPARK_ENV=docker`, nó sẽ tự nhận `master("spark://spark-master:7077")`.

Mọi URL kết nối sẽ giữ nguyên là `thrift://hive-metastore:9083` nhờ bước mapping ở mục 1.
