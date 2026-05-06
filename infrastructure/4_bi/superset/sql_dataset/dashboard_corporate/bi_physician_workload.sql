/* 
   ==========================================================================
   DATASET: Phân tích khối lượng công việc của Bác sĩ (Physician Workload)
   ==========================================================================
   MỤC ĐÍCH: Đánh giá số lượng bệnh nhân và số lượng dịch vụ mà mỗi bác sĩ 
             đang đảm nhận để điều phối nhân sự hợp lý.
   
   ĐỐI TƯỢNG: Phòng Kế hoạch tổng hợp, Trưởng khoa.
   
   GỢI Ý CHART: 
   - Bar Chart: Tổng số ca tiếp nhận theo bác sĩ.
   - Stacked Bar Chart: Số lượng dịch vụ chi định theo khoa/phòng.
   ==========================================================================
*/
SELECT 
    nv.TEN_NHAN_VIEN,
    kp.TEN_DON_VI as khoa_phong,
    f.THOI_GIAN_CHI_DINH::DATE as ngay,
    COUNT(DISTINCT f.MA_HO_SO) as so_ca_tiep_nhan,
    SUM(f.SO_LUONG) as tong_so_dich_vu_chi_dinh,
    -- Phân tích tài chính cơ bản đi kèm
    SUM(f.TIEN_BH_THANH_TOAN + f.TIEN_NB_TU_TRA + f.TIEN_NB_CUNG_CHI_TRA) as tong_gia_tri_chi_dinh
FROM data_mart.fact_chi_dinh_dich_vu f
INNER JOIN data_mart.dim_nhan_vien nv ON f.NHAN_VIEN_CHI_DINH_PK = nv.NHAN_VIEN_PK
INNER JOIN data_mart.dim_khoa_phong kp ON f.KHOA_CHI_DINH_PK = kp.DON_VI_PK
WHERE f.IS_ACTIVE = true
GROUP BY 1, 2, 3
