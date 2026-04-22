{{ config(
    materialized='table',
    schema='data_mart'
) }}

{#
    FACT_DOANH_THU_THEO_KHOA - Bảng Fact Tổng hợp Doanh thu theo Khoa & Thời gian
#}

WITH base AS (
    SELECT
        KHOA_CHI_DINH_PK AS KHOA_PK,
        DATE_TRUNC('day', THOI_GIAN_CHI_DINH)::DATE AS NGAY,
        
        -- Sử dụng trực tiếp dữ liệu NUMERIC từ fact_chi_dinh_dich_vu
        (GIA_GOC * SO_LUONG)                                 AS DOANH_THU_GOC,
        TIEN_BH_THANH_TOAN                                   AS TIEN_BH,
        TIEN_NB_TU_TRA                                       AS TIEN_NB_TU_TRA,
        TIEN_NB_CUNG_CHI_TRA                                 AS TIEN_NB_CUNG_CHI_TRA,
        
        -- Phục vụ count distinct
        BENH_NHAN_PK,
        DOT_DIEU_TRI_PK,
        SO_LUONG
    FROM {{ ref('fact_chi_dinh_dich_vu') }}
    WHERE IS_ACTIVE = true 
      AND THOI_GIAN_CHI_DINH IS NOT NULL
)
,
aggregated AS (
    SELECT
        KHOA_PK,
        NGAY,
        EXTRACT(WEEK FROM NGAY)    AS TUAN,
        EXTRACT(MONTH FROM NGAY)   AS THANG,
        EXTRACT(QUARTER FROM NGAY) AS QUY,
        EXTRACT(YEAR FROM NGAY)    AS NAM,
        
        SUM(DOANH_THU_GOC) AS TONG_DOANH_THU_GOC,
        SUM(TIEN_BH + TIEN_NB_TU_TRA + TIEN_NB_CUNG_CHI_TRA) AS TONG_DOANH_THU_THUC,
        SUM(TIEN_BH) AS TONG_TIEN_BH,
        SUM(TIEN_NB_TU_TRA) AS TONG_TIEN_NB_TU_TRA,
        SUM(TIEN_NB_CUNG_CHI_TRA) AS TONG_TIEN_NB_CUNG_CHI_TRA,
        
        SUM(SO_LUONG) AS TONG_SO_LUONG_DICH_VU,
        COUNT(*) AS SO_LUONG_CHI_DINH,
        COUNT(DISTINCT BENH_NHAN_PK) AS SO_BEN_NHAN,
        COUNT(DISTINCT DOT_DIEU_TRI_PK) AS SO_DOT_DIEU_TRI
    FROM base
    GROUP BY 1, 2
)

SELECT 
    agg.*,
    dkp.TEN_DON_VI AS TEN_KHOA
FROM aggregated agg
LEFT JOIN {{ ref('dim_khoa_phong') }} dkp
    ON agg.KHOA_PK = dkp.DON_VI_PK
