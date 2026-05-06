/* 
   ==========================================================================
   DATASET: Quản lý hợp đồng khám sức khỏe đoàn
   ==========================================================================
   MỤC ĐÍCH: Theo dõi danh sách, trạng thái và số lượng người khám thực tế.
   
   GỢI Ý CHART: 
   - Big Number: Tổng số người đã khám xong.
   - Bar Chart: So sánh số người khám giữa các công ty.
   ==========================================================================
*/
SELECT 
    f.TEN_HOP_DONG,
    f.SO_HOP_DONG,
    f.TRANG_THAI,
    f.DIA_DIEM_KHAM, 
    f.CREATED_AT::DATE as ngay_ghi_nhan,
    -- Đếm chính xác số người (tránh lặp)
    COUNT(DISTINCT f.KHAM_SUC_KHOE_PK) as so_luong_nguoi_kham
FROM data_mart.fact_kham_suc_khoe f
GROUP BY 1, 2, 3, 4, 5
