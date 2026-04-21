{{ config(
    materialized='table',
    schema='data_mart'
) }}

WITH latest_sat AS (
    SELECT 
        HOP_DONG_KSK_PK,
        ten,
        so_hop_dong,
        ngay_hieu_luc,
        trang_thai,
        LOAD_DATETIME,
        ROW_NUMBER() OVER (PARTITION BY HOP_DONG_KSK_PK ORDER BY LOAD_DATETIME DESC) as row_num
    FROM {{ ref('sat_hop_dong_ksk') }}
),

final AS (
    SELECT
        h.HOP_DONG_KSK_PK,
        h.id AS HOP_DONG_KSK_ID,
        s.ten AS TEN_HOP_DONG,
        s.so_hop_dong AS SO_HOP_DONG,
        s.ngay_hieu_luc AS NGAY_HIEU_LUC,
        s.trang_thai AS TRANG_THAI,
        h.LOAD_DATETIME AS CREATED_AT
    FROM {{ ref('hub_hop_dong_ksk') }} h
    LEFT JOIN latest_sat s ON h.HOP_DONG_KSK_PK = s.HOP_DONG_KSK_PK AND s.row_num = 1
)

SELECT * FROM final
