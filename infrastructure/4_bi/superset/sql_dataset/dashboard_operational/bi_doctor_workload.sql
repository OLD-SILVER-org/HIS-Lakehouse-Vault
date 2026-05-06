/* 
   DATASET: Hiệu suất và Tải trọng Bác sĩ (Doctor Workload) - Có hỗ trợ lọc thời gian
   MỤC ĐÍCH: Theo dõi số lượng bệnh nhân mỗi bác sĩ đảm nhận theo thời gian.
*/
SELECT 
    f.thoi_gian_kham::DATE as ngay_kham,
    f.ten_bac_si_kham as bac_si,
    -- Đếm số ca khám trong ngày của bác sĩ
    COUNT(*) as so_luot_kham,
    -- Đếm số bệnh nhân duy nhất (tránh đếm trùng nếu 1 NB khám nhiều lần/ngày)
    COUNT(DISTINCT f.benh_nhan_pk) as so_benh_nhan_unique
FROM data_mart.fact_kham_benh f
WHERE f.thoi_gian_kham IS NOT NULL
  AND f.ten_bac_si_kham IS NOT NULL
GROUP BY 1, 2
ORDER BY 1 DESC, 3 DESC;
