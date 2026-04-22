SELECT 
    f.CREATED_AT as ngay_chi_dinh,
    d.TEN_DICH_VU,
    k.TEN_DON_VI as ten_khoa,
    dt.MA_HO_SO,
    f.SO_LUONG,
    f.GIA_GOC,
    f.TIEN_NB_TU_TRA,
    f.TIEN_BH_THANH_TOAN,

    (COALESCE(f.TIEN_BH_THANH_TOAN, 0) + COALESCE(f.TIEN_NB_TU_TRA, 0) + COALESCE(f.TIEN_NB_CUNG_CHI_TRA, 0)) as doanh_thu_thuc
FROM public_data_mart.fact_chi_dinh_dich_vu f
LEFT JOIN public_data_mart.dim_dich_vu d ON f.DICH_VU_PK = d.DICH_VU_PK
LEFT JOIN public_data_mart.dim_khoa_phong k ON f.KHOA_CHI_DINH_PK = k.DON_VI_PK
LEFT JOIN public_data_mart.dim_dot_dieu_tri dt ON f.DOT_DIEU_TRI_PK = dt.DOT_DIEU_TRI_PK
WHERE f.IS_ACTIVE = true 
  AND f.TIEN_NB_TU_TRA > 0  
ORDER BY f.TIEN_NB_TU_TRA DESC;