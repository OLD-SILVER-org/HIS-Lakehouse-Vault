{{ config(
    materialized='table',
    schema='data_mart'
) }}

{#
    FACT_NGUON_NB - Bảng Fact (Factless) sự kiện Nguồn tiếp nhận Bệnh nhân
    Grain: Mỗi dòng = 1 nguồn chuyển/giới thiệu bệnh nhân gắn với 1 đợt điều trị
    Nguồn: link_nguon_nb + sat_nguon_nb
    FK Dims: DOT_DIEU_TRI_PK, BENH_NHAN_PK (qua link_benh_nhan_dieu_tri), NGUON_NB_PK
    Ghi chú: Đây là "factless fact" - chủ yếu dùng để phân tích kênh tiếp nhận NB
             (tự đến, chuyển viện, giới thiệu, KSK...) hơn là đo lường số liệu tài chính.
#}

WITH latest_sat AS (
    SELECT
        LINK_NGUON_NB_PK,
        nguon_nb_id,
        nguoi_gioi_thieu_id,
        ghi_chu,
        ROW_NUMBER() OVER (PARTITION BY LINK_NGUON_NB_PK ORDER BY LOAD_DATETIME DESC) AS row_num
    FROM {{ ref('sat_nguon_nb') }}
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
        lk.LINK_NGUON_NB_PK,

        -- === Dimension Keys (FK) ===
        lk.DOT_DIEU_TRI_PK,
        lk.NGUON_NB_PK,
        bn.BENH_NHAN_PK,

        -- === Human Readable Names (Added per User Request) ===
        dbn.MA_NB,
        dbn.TEN_BENH_NHAN,
        ddt.MA_HO_SO,

        -- === Attributes / Descriptors ===
        s.nguon_nb_id                   AS NGUON_NB_ID,
        s.nguoi_gioi_thieu_id           AS NGUOI_GIOI_THIEU_ID,
        s.ghi_chu                       AS GHI_CHU,

        -- === Metadata ===
        lk.LOAD_DATETIME                AS CREATED_AT

    FROM {{ ref('link_nguon_nb') }} lk
    LEFT JOIN latest_sat s
        ON lk.LINK_NGUON_NB_PK = s.LINK_NGUON_NB_PK AND s.row_num = 1
    LEFT JOIN link_bn bn
        ON lk.DOT_DIEU_TRI_PK = bn.DOT_DIEU_TRI_PK

    -- Joins with Dim for Readable Names
    LEFT JOIN {{ ref('dim_benh_nhan') }} dbn
        ON bn.BENH_NHAN_PK = dbn.BENH_NHAN_PK
    LEFT JOIN {{ ref('dim_dot_dieu_tri') }} ddt
        ON lk.DOT_DIEU_TRI_PK = ddt.DOT_DIEU_TRI_PK
)

SELECT * FROM final
