/* 
   ==========================================================================
   DATASET: Hiệu suất Lâm sàng và Chỉ định của Bác sĩ
   ==========================================================================
   MỤC ĐÍCH: Đánh giá khối lượng công việc và giá trị kinh tế mà từng bác sĩ 
             hoặc khoa phòng tạo ra thông qua các chỉ định dịch vụ.
   
   ĐỐI TƯỢNG: Trưởng đơn vị/khoa, Ban điều hành bệnh viện.
   
   GỢI Ý CHART: 
   - Horizontal Bar Chart: Top 10 bác sĩ có giá trị chỉ định cao nhất.
   - Heatmap: Mật độ chỉ định theo khoa phòng và ngày trong tuần.
   - Treemap: Tỷ trọng doanh thu chỉ định giữa các khoa.
   ==========================================================================
*/
SELECT 
    nv.TEN_NHAN_VIEN,
    kp.TEN_DON_VI as khoa_phong,
    f.THOI_GIAN_CHI_DINH::DATE as ngay,
    COUNT(DISTINCT f.MA_HO_SO) as so_ca_tiep_nhan,
    SUM(f.SO_LUONG) as tong_so_dich_vu,
    ROUND(SUM(f.TIEN_BH_THANH_TOAN + f.TIEN_NB_TU_TRA + f.TIEN_NB_CUNG_CHI_TRA),2) as tong_gia_tri_chi_dinh,
    ROUND(AVG(f.TIEN_NB_TU_TRA),2) as trung_binh_thu_tu_nb
FROM public_data_mart.fact_chi_dinh_dich_vu f
INNER JOIN public_data_mart.dim_nhan_vien nv ON f.NHAN_VIEN_CHI_DINH_PK = nv.NHAN_VIEN_PK
INNER JOIN public_data_mart.dim_khoa_phong kp ON f.KHOA_CHI_DINH_PK = kp.DON_VI_PK
WHERE f.IS_ACTIVE = true
GROUP BY 1, 2, 3
