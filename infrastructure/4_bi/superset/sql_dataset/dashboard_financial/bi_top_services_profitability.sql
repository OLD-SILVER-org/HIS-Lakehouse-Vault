/* 
   ==========================================================================
   DATASET: Phân tích Dịch vụ và Hiệu quả Kinh tế (Service Profitability)
   ==========================================================================
   MỤC ĐÍCH: Xác định các dịch vụ có tần suất sử dụng cao nhất và mang lại doanh thu
             lớn nhất cho bệnh viện.
   
   ĐỐI TƯỢNG: Ban Giám đốc, Phòng Tài chính - Kế toán.
   
   GỢI Ý CHART: 
   - Treemap: Tỷ trọng doanh thu giữa các nhóm dịch vụ.
   - Horizontal Bar Chart: Top 20 dịch vụ có doanh thu cao nhất.
   - Scatter Plot: Tần suất sử dụng vs. Doanh thu trung bình mỗi lượt.
   ==========================================================================
*/
SELECT 
    dv.TEN_DICH_VU,
    dv.LOAI_DICH_VU,
    f.THOI_GIAN_CHI_DINH::DATE as ngay,
    SUM(f.SO_LUONG) as tong_so_luong,
    -- Doanh thu thực thu
    SUM(f.TIEN_BH_THANH_TOAN + f.TIEN_NB_TU_TRA + f.TIEN_NB_CUNG_CHI_TRA) as tong_doanh_thu,
    -- Phân rã nguồn thu
    SUM(f.TIEN_BH_THANH_TOAN) as doanh_thu_bhyt,
    SUM(f.TIEN_NB_TU_TRA) as doanh_thu_vien_phi
FROM public_data_mart.fact_chi_dinh_dich_vu f
INNER JOIN public_data_mart.dim_dich_vu dv ON f.DICH_VU_PK = dv.DICH_VU_PK
WHERE f.IS_ACTIVE = true
GROUP BY 1, 2, 3
ORDER BY tong_doanh_thu DESC
