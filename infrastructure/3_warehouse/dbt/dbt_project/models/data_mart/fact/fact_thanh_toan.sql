{{ config(
    materialized='table',
    schema='data_mart'
) }}

{#
    FACT_THANH_TOAN - Bảng Fact sự kiện Thanh toán
    Grain: Mỗi dòng = 1 phiếu thu/hóa đơn thanh toán
    Nguồn: link_thanh_toan + sat_thanh_toan
    FK Dims: PHIEU_THU_PK, DOT_DIEU_TRI_PK, NHAN_VIEN_THU_NGAN_PK, BENH_NHAN_PK
#}

WITH latest_sat AS (
    SELECT
        PHIEU_THU_PK,
        so_phieu,
        loai_phieu_thu,
        doi_tuong_kcb,
        thanh_tien,
        thanh_toan,
        tien_bh_thanh_toan,
        tien_nb_cung_chi_tra,
        tien_nb_tu_tra,
        tien_nb_phu_thu,
        tien_nguon_khac,
        tien_giam_gia,
        tien_hoan_tra,
        tien_mien_giam_dich_vu,
        tien_mien_giam_phieu_thu,
        phan_tram_mien_giam,
        hinh_thuc_mien_giam,
        hoan_ung,
        thoi_gian_tao_phieu,
        thoi_gian_thanh_toan,
        thoi_gian_huy_thanh_toan,
        trang_thai_hoa_don,
        active,
        deleted,
        ROW_NUMBER() OVER (PARTITION BY PHIEU_THU_PK ORDER BY LOAD_DATETIME DESC) as row_num
    FROM {{ ref('sat_thanh_toan') }}
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
        lk.LINK_THANH_TOAN_PK,

        -- === Dimension Keys (FK) ===
        lk.PHIEU_THU_PK,
        lk.DOT_DIEU_TRI_PK,
        lk.NHAN_VIEN_THU_NGAN_PK,
        bn.BENH_NHAN_PK,

        -- === Human Readable Names (Added per User Request) ===
        dbn.MA_NB,
        dbn.TEN_BENH_NHAN,
        dnv.TEN_NHAN_VIEN        AS TEN_NHAN_VIEN_THU_NGAN,
        ddt.MA_HO_SO,

        -- === Identifiers ===
        s.so_phieu                  AS SO_PHIEU,
        s.loai_phieu_thu            AS LOAI_PHIEU_THU,
        s.doi_tuong_kcb             AS DOI_TUONG_KCB,

        -- === Measures (Tài chính) ===
        CAST(NULLIF(s.thanh_tien::TEXT, '') AS NUMERIC)                AS THANH_TIEN,
        CAST(NULLIF(s.thanh_toan::TEXT, '') AS NUMERIC)                AS THANH_TOAN,
        CAST(NULLIF(s.tien_bh_thanh_toan::TEXT, '') AS NUMERIC)        AS TIEN_BH_THANH_TOAN,
        CAST(NULLIF(s.tien_nb_cung_chi_tra::TEXT, '') AS NUMERIC)      AS TIEN_NB_CUNG_CHI_TRA,
        CAST(NULLIF(s.tien_nb_tu_tra::TEXT, '') AS NUMERIC)            AS TIEN_NB_TU_TRA,
        CAST(NULLIF(s.tien_nb_phu_thu::TEXT, '') AS NUMERIC)           AS TIEN_NB_PHU_THU,
        CAST(NULLIF(s.tien_nguon_khac::TEXT, '') AS NUMERIC)           AS TIEN_NGUON_KHAC,
        CAST(NULLIF(s.tien_giam_gia::TEXT, '') AS NUMERIC)             AS TIEN_GIAM_GIA,
        CAST(NULLIF(s.tien_hoan_tra::TEXT, '') AS NUMERIC)             AS TIEN_HOAN_TRA,
        CAST(NULLIF(s.tien_mien_giam_dich_vu::TEXT, '') AS NUMERIC)    AS TIEN_MIEN_GIAM_DICH_VU,
        CAST(NULLIF(s.tien_mien_giam_phieu_thu::TEXT, '') AS NUMERIC)  AS TIEN_MIEN_GIAM_PHIEU_THU,

        -- === Discount Attributes ===
        s.phan_tram_mien_giam       AS PHAN_TRAM_MIEN_GIAM,
        s.hinh_thuc_mien_giam       AS HINH_THUC_MIEN_GIAM,
        s.hoan_ung                  AS HOAN_UNG,

        -- === Timestamps ===
        s.thoi_gian_tao_phieu       AS THOI_GIAN_TAO_PHIEU,
        s.thoi_gian_thanh_toan      AS THOI_GIAN_THANH_TOAN,
        s.thoi_gian_huy_thanh_toan  AS THOI_GIAN_HUY_THANH_TOAN,

        -- === Status ===
        s.trang_thai_hoa_don        AS TRANG_THAI_HOA_DON,
        s.active                    AS IS_ACTIVE,

        -- === Metadata ===
        lk.LOAD_DATETIME            AS CREATED_AT

    FROM {{ ref('link_thanh_toan') }} lk
    LEFT JOIN latest_sat s
        ON lk.PHIEU_THU_PK = s.PHIEU_THU_PK AND s.row_num = 1
    LEFT JOIN link_bn bn
        ON lk.DOT_DIEU_TRI_PK = bn.DOT_DIEU_TRI_PK

    -- Joins with Dim for Readable Names
    LEFT JOIN {{ ref('dim_benh_nhan') }} dbn
        ON bn.BENH_NHAN_PK = dbn.BENH_NHAN_PK
    LEFT JOIN {{ ref('dim_nhan_vien') }} dnv
        ON lk.NHAN_VIEN_THU_NGAN_PK = dnv.NHAN_VIEN_PK
    LEFT JOIN {{ ref('dim_dot_dieu_tri') }} ddt
        ON lk.DOT_DIEU_TRI_PK = ddt.DOT_DIEU_TRI_PK

    WHERE s.deleted = 0 OR s.deleted IS NULL
)

SELECT * FROM final
