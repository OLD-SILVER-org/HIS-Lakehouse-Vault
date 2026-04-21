{{ config(
    materialized='table',
    schema='data_mart'
) }}

{#
    FACT_CHI_DINH_DICH_VU - Bảng Fact sự kiện Chỉ định Dịch vụ
    Grain: Mỗi dòng = 1 dịch vụ được bác sĩ chỉ định trong 1 đợt điều trị
    Nguồn: link_chi_dinh_dich_vu + sat_chi_dinh_dich_vu
    FK Dims: DOT_DIEU_TRI_PK, DICH_VU_PK, NHAN_VIEN_PK (BS chỉ định), KHOA_PK, BENH_NHAN_PK
#}

WITH latest_sat AS (
    SELECT
        LINK_CHI_DINH_DICH_VU_PK,
        doi_tuong_kcb,
        ghi_chu,
        gia_bao_hiem,
        gia_goc,
        gia_khong_bao_hiem,
        so_luong,
        thoi_gian_chi_dinh,
        tien_bh_thanh_toan,
        tien_nb_cung_chi_tra,
        tien_nb_tu_tra,
        active,
        deleted,
        ROW_NUMBER() OVER (PARTITION BY LINK_CHI_DINH_DICH_VU_PK ORDER BY LOAD_DATETIME DESC) as row_num
    FROM {{ ref('sat_chi_dinh_dich_vu') }}
),

-- Lấy BENH_NHAN_PK thông qua DOT_DIEU_TRI_PK
link_bn AS (
    SELECT
        DOT_DIEU_TRI_PK,
        BENH_NHAN_PK
    FROM {{ ref('link_benh_nhan_dieu_tri') }}
),

final AS (
    SELECT
        lk.LINK_CHI_DINH_DICH_VU_PK,

        -- === Dimension Keys (FK) ===
        lk.DOT_DIEU_TRI_PK,
        lk.DICH_VU_PK,
        lk.NHAN_VIEN_PK          AS NHAN_VIEN_CHI_DINH_PK,
        lk.KHOA_PK               AS KHOA_CHI_DINH_PK,
        bn.BENH_NHAN_PK,

        -- === Human Readable Names (Added per User Request) ===
        dbn.MA_NB,
        dbn.TEN_BENH_NHAN,
        ddv.TEN_DICH_VU,
        dnv.TEN_NHAN_VIEN        AS TEN_NHAN_VIEN_CHI_DINH,
        dkp.TEN_DON_VI           AS TEN_KHOA_CHI_DINH,
        ddt.MA_HO_SO,

        -- === Measures (Số tiền / Số lượng) ===
        CAST(NULLIF(s.so_luong::TEXT, '') AS NUMERIC)                AS SO_LUONG,
        CAST(NULLIF(s.gia_goc::TEXT, '') AS NUMERIC)                 AS GIA_GOC,
        CAST(NULLIF(s.gia_bao_hiem::TEXT, '') AS NUMERIC)            AS GIA_BAO_HIEM,
        CAST(NULLIF(s.gia_khong_bao_hiem::TEXT, '') AS NUMERIC)      AS GIA_KHONG_BAO_HIEM,
        CAST(NULLIF(s.tien_bh_thanh_toan::TEXT, '') AS NUMERIC)      AS TIEN_BH_THANH_TOAN,
        CAST(NULLIF(s.tien_nb_cung_chi_tra::TEXT, '') AS NUMERIC)    AS TIEN_NB_CUNG_CHI_TRA,
        CAST(NULLIF(s.tien_nb_tu_tra::TEXT, '') AS NUMERIC)          AS TIEN_NB_TU_TRA,

        -- === Attributes ===
        s.doi_tuong_kcb           AS DOI_TUONG_KCB,
        s.ghi_chu                 AS GHI_CHU,
        s.thoi_gian_chi_dinh      AS THOI_GIAN_CHI_DINH,
        s.active                  AS IS_ACTIVE,

        -- === Metadata ===
        lk.LOAD_DATETIME          AS CREATED_AT

    FROM {{ ref('link_chi_dinh_dich_vu') }} lk
    LEFT JOIN latest_sat s
        ON lk.LINK_CHI_DINH_DICH_VU_PK = s.LINK_CHI_DINH_DICH_VU_PK AND s.row_num = 1
    LEFT JOIN link_bn bn
        ON lk.DOT_DIEU_TRI_PK = bn.DOT_DIEU_TRI_PK

    -- Joins with Dim for Readable Names
    LEFT JOIN {{ ref('dim_benh_nhan') }} dbn
        ON bn.BENH_NHAN_PK = dbn.BENH_NHAN_PK
    LEFT JOIN {{ ref('dim_dich_vu') }} ddv
        ON lk.DICH_VU_PK = ddv.DICH_VU_PK
    LEFT JOIN {{ ref('dim_nhan_vien') }} dnv
        ON lk.NHAN_VIEN_PK = dnv.NHAN_VIEN_PK
    LEFT JOIN {{ ref('dim_khoa_phong') }} dkp
        ON lk.KHOA_PK = dkp.DON_VI_PK
    LEFT JOIN {{ ref('dim_dot_dieu_tri') }} ddt
        ON lk.DOT_DIEU_TRI_PK = ddt.DOT_DIEU_TRI_PK

    WHERE s.deleted = 0 OR s.deleted IS NULL
)

SELECT * FROM final
