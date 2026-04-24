/* 
   ==========================================================================
   DATASET: Tổng hợp doanh thu và sản lượng theo Khoa Phòng
   ==========================================================================
   MỤC ĐÍCH: Dashboard quản trị giúp theo dõi nhanh doanh thu thực thu, 
             doanh thu BHYT và workload (số lượng dịch vụ) của từng khoa.
   
   GỢI Ý CHART: 
   - Table View (Heatmap): So sánh doanh thu thực giữa các khoa theo ngày.
   - Line Chart: Xu hướng 'rev_per_patient' để đánh giá chất lượng đơn hàng.
   - Bar Chart: So sánh số đợt điều trị và số bệnh nhân để xem tỉ lệ quay lại.
   ==========================================================================
*/
SELECT 
    f.NGAY,
    f.TEN_KHOA,
    f.TONG_DOANH_THU_THUC,
    f.TONG_TIEN_BH,
    f.TONG_SO_LUONG_DICH_VU,
    f.SO_BEN_NHAN,
    f.SO_DOT_DIEU_TRI,
    -- Average Revenue per Patient: Chỉ số giá trị trung bình trên mỗi người bệnh
    CASE 
        WHEN f.SO_BEN_NHAN > 0 THEN ROUND(f.TONG_DOANH_THU_THUC / f.SO_BEN_NHAN ,2)
        ELSE 0 
    END AS rev_per_patient
FROM public_data_mart.fact_doanh_thu_theo_khoa f
ORDER BY f.NGAY DESC, f.TONG_DOANH_THU_THUC DESC