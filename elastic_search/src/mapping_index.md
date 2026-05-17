# Elasticsearch Index Mapping Recommendations

Để tối ưu tài nguyên và tập trung vào các use-case mang lại giá trị cao nhất cho Elasticsearch (tìm kiếm full-text tốc độ cao và tra cứu nhanh), dưới đây là 3 bảng quan trọng nhất nên được đồng bộ:

## 1. `dm_benh_nhan` (Danh sách bệnh nhân)
- **Mục đích**: Phục vụ tính năng tra cứu bệnh nhân siêu tốc từ mọi màn hình (Tiếp đón, Khám bệnh, Thu ngân). Hỗ trợ tìm kiếm mờ (fuzzy search) ngay cả khi người dùng gõ sai chính tả tên bệnh nhân.
- **Trường (Fields) cần Index**: `ten_nb`, `ten_nb_khong_dau`, `so_dien_thoai`, `email`, `ma_nb`.

## 2. `dm_dich_vu` (Danh mục Dịch vụ)
- **Mục đích**: Làm API Autocomplete (gợi ý từ khóa) khi bác sĩ gõ tên dịch vụ để ra y lệnh. ES xử lý việc này nhanh và mượt hơn nhiều so với LIKE query trong PostgreSQL.
- **Trường (Fields) cần Index**: `ten`, `code_dichvu`, `ten_tuong_duong`, `viet_tat`.

## 3. `ct_dot_dieu_tri` (Đợt điều trị / Lượt khám)
- **Mục đích**: Trung tâm của dữ liệu nghiệp vụ. Cho phép tra cứu nhanh lịch sử khám chữa bệnh của một người, lọc danh sách bệnh án đang nằm viện, hoặc thống kê nhanh lưu lượng bệnh nhân (real-time dashboard).
- **Trường (Fields) cần Index**: `ma_benh_an`, `ten_nb` (nên join từ `dm_benh_nhan` vào), `so_dien_thoai`, `thoi_gian_vao_vien`, `thoi_gian_ra_vien`, `trang_thai`.

---

## Gợi ý kiến trúc (Best Practice)
Thay vì đẩy rời rạc từng bảng, đối với `ct_dot_dieu_tri`, bạn nên dùng Spark để **Join** (denormalize) luôn các thông tin cơ bản như Tên Bệnh Nhân, Số điện thoại từ `dm_benh_nhan` vào một document duy nhất trước khi đẩy lên ES. 

Ví dụ một document trong index `idx_dot_dieu_tri`:
```json
{
  "ma_benh_an": "BA123456",
  "thoi_gian_vao_vien": "2023-10-01T08:00:00Z",
  "benh_nhan": {
    "ma_nb": "BN999",
    "ten_nb": "Nguyen Van A",
    "so_dien_thoai": "0987654321"
  }
}
```
Cách này giúp ES không phải xử lý relation, tốc độ tìm kiếm trả về sẽ đạt mức dưới 10ms.
