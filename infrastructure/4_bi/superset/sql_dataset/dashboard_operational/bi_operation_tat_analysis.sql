/* 
   ==========================================================================
   DATASET: Phân tích thời gian xử lý kỹ thuật (TAT - Turnaround Time)
   ==========================================================================
   MỤC ĐÍCH: Theo dõi thời gian từ lúc tiếp nhận chỉ định đến khi có kết quả 
             để đánh giá hiệu suất của các phòng kỹ thuật (X-Quang, Xét nghiệm).
   
   ĐỐI TƯỢNG: Trưởng khoa Cập mẫu, Trưởng khoa CLS, Ban Giám đốc.
   
   GỢI Ý CHART: 
   - Big Number: Thời gian xử lý trung bình (phút).
   - Pie Chart: Tỷ lệ ca "Đạt chuẩn" vs "Chậm".
   - Line Chart: Xu hướng TAT trung bình theo ngày.
   ==========================================================================
*/
SELECT 
    f.TEN_BENH_NHAN,
    f.MA_HO_SO,
    -- Tính thời gian chờ (phút) từ lúc tiếp nhận đến khi có kết quả
    EXTRACT(EPOCH FROM (f.THOI_GIAN_HOAN_THANH - f.THOI_GIAN_TIEP_NHAN))/60 as phut_xu_ly,
    CASE 
        WHEN EXTRACT(EPOCH FROM (f.THOI_GIAN_HOAN_THANH - f.THOI_GIAN_TIEP_NHAN))/60 > 60 THEN 'Chậm (>60p)'
        ELSE 'Đạt chuẩn'
    END as trang_thai_toc_do,
    f.THOI_GIAN_TIEP_NHAN::DATE as ngay_thuc_hien
FROM public_data_mart.fact_dv_ky_thuat f
WHERE f.THOI_GIAN_HOAN_THANH IS NOT NULL 
  AND f.THOI_GIAN_TIEP_NHAN IS NOT NULL
