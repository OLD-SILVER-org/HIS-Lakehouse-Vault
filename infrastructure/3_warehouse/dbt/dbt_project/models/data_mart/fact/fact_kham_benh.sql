{{ config(
    materialized='table',
    schema='data_mart'
) }}

{#
    FACT_KHAM_BENH - Bảng Fact sự kiện Khám bệnh
    Grain: Mỗi dòng = 1 lượt khám (1 Bác sĩ khám trong 1 Đợt điều trị)
    Nguồn: link_kham_benh + sat_kham_benh
    FK Dims: BENH_NHAN_PK (qua link_benh_nhan_dieu_tri), DOT_DIEU_TRI_PK, NHAN_VIEN_KHAM_PK
#}

WITH latest_sat AS (
    SELECT
        LINK_KHAM_BENH_PK,
        dot_kham_moi,
        thoi_gian_kham,
        thoi_gian_ket_luan,
        active,
        deleted,
        ROW_NUMBER() OVER (PARTITION BY LINK_KHAM_BENH_PK ORDER BY LOAD_DATETIME DESC) as row_num
    FROM {{ ref('sat_kham_benh') }}
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
        lk.LINK_KHAM_BENH_PK,

        -- === Dimension Keys (FK) ===
        lk.DOT_DIEU_TRI_PK,
        lk.NHAN_VIEN_KHAM_PK,
        bn.BENH_NHAN_PK,

        -- === Human Readable Names (Added per User Request) ===
        dbn.MA_NB,
        dbn.TEN_BENH_NHAN,
        dnv.TEN_NHAN_VIEN AS TEN_BAC_SI_KHAM,
        ddt.MA_HO_SO,

        -- === Measures & Attributes ===
        s.dot_kham_moi AS DOT_KHAM_MOI,
        s.thoi_gian_kham AS THOI_GIAN_KHAM,
        s.thoi_gian_ket_luan AS THOI_GIAN_KET_LUAN,
        s.active AS IS_ACTIVE,

        -- === Metadata ===
        lk.LOAD_DATETIME AS CREATED_AT

    FROM {{ ref('link_kham_benh') }} lk
    LEFT JOIN latest_sat s
        ON lk.LINK_KHAM_BENH_PK = s.LINK_KHAM_BENH_PK AND s.row_num = 1
    LEFT JOIN link_bn bn
        ON lk.DOT_DIEU_TRI_PK = bn.DOT_DIEU_TRI_PK
    
    -- Joins with Dim for Readable Names
    LEFT JOIN {{ ref('dim_benh_nhan') }} dbn
        ON bn.BENH_NHAN_PK = dbn.BENH_NHAN_PK
    LEFT JOIN {{ ref('dim_nhan_vien') }} dnv
        ON lk.NHAN_VIEN_KHAM_PK = dnv.NHAN_VIEN_PK
    LEFT JOIN {{ ref('dim_dot_dieu_tri') }} ddt
        ON lk.DOT_DIEU_TRI_PK = ddt.DOT_DIEU_TRI_PK

    WHERE s.deleted = 0 OR s.deleted IS NULL
)

SELECT * FROM final
