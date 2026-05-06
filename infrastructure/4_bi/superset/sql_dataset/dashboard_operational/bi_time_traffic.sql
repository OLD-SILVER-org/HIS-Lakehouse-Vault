/* 
   ==========================================================================
   DATASET: Phân tích Giờ cao điểm và Phân bổ lượt khám (Peak Hour & Traffic Analysis)
   ==========================================================================
   MỤC ĐÍCH: Xác định xem trong ngày, khung giờ nào bệnh nhân đến khám đông nhất 
                và thứ mấy trong tuần là bận rộn nhất.
   
   ĐỐI TƯỢNG: Ban Giám đốc.
   
   GỢI Ý CHART: 
   - Heatmap: Trục X là Thứ, Trục Y là Giờ, màu sắc thể hiện độ đông đúc.
   - Bar Chart: Tổng lượt khám theo từng khung giờ để thấy đỉnh nhọn (Peak).
   ==========================================================================
*/
SELECT 
    f.thoi_gian_kham::DATE as ngay, -- Thêm cột này để lọc thời gian
    -- Lấy giờ (0-23)
    EXTRACT(HOUR FROM f.thoi_gian_kham) as gio_trong_ngay,
    -- Lấy tên thứ (Thứ 2, Thứ 3...)
    TO_CHAR(f.thoi_gian_kham, 'Day') as thu_trong_tuan,
    -- Đếm số lượt khám
    COUNT(*) as so_luot_kham
FROM data_mart.fact_kham_benh f
WHERE f.thoi_gian_kham IS NOT NULL
GROUP BY 1, 2, 3
ORDER BY 1, 2
