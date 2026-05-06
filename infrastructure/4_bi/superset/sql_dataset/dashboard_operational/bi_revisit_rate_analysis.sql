/* 
   ==========================================================================
   DATASET: Phân tích Tỷ lệ quay lại của Bệnh nhân (Retention Rate)
   ==========================================================================
   MỤC ĐÍCH: Đánh giá chất lượng phục vụ và uy tín thương hiệu thông qua 
             việc bệnh nhân có quay lại khám lần 2, lần 3... hay không.
   
   ĐỐI TƯỢNG: Ban Giám đốc, Phòng Quản lý Chất lượng, Chăm sóc khách hàng.
   
   GỢI Ý CHART: 
   - Time-series Line Chart: Xu hướng Tỷ lệ quay lại (%) theo tháng.
   - Dual Axis Chart: So sánh Bệnh nhân mới vs Bệnh nhân quay lại.
   ==========================================================================
*/
SELECT 
    ngay_kham,
    COUNT(DISTINCT MA_NB) as tong_benh_nhan,
    COUNT(DISTINCT MA_NB) FILTER (WHERE so_lan_kham > 1) as benh_nhan_cu,
    ROUND((COUNT(DISTINCT MA_NB) FILTER (WHERE so_lan_kham > 1) * 100.0 / NULLIF(COUNT(DISTINCT MA_NB), 0)), 2) as ty_le_quay_lai
FROM (
    SELECT 
        b.MA_NB,
        k.THOI_GIAN_KHAM::DATE as ngay_kham,
        COUNT(*) OVER(PARTITION BY b.MA_NB) as so_lan_kham
    FROM data_mart.dim_benh_nhan b
    JOIN data_mart.fact_kham_benh k ON b.BENH_NHAN_PK = k.BENH_NHAN_PK
) sub
GROUP BY 1
ORDER BY 1 DESC
