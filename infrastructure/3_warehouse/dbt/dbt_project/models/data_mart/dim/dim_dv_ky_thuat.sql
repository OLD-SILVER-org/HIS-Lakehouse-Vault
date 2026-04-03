{{ config(
    materialized='table',
    schema='data_mart'
) }}

WITH latest_sat AS (
    SELECT 
        DV_KY_THUAT_PK,
        trang_thai,
        thoi_gian_bat_dau,
        thoi_gian_hoan_thanh,
        ROW_NUMBER() OVER (PARTITION BY DV_KY_THUAT_PK ORDER BY LOAD_DATETIME DESC) as row_num
    FROM {{ ref('sat_dv_ky_thuat') }}
),

final AS (
    SELECT
        h.DV_KY_THUAT_PK,
        h.id AS MA_DV_KY_THUAT,
        s.trang_thai AS TRANG_THAI_THUC_HIEN,
        s.thoi_gian_bat_dau AS THOI_GIAN_BAT_DAU,
        s.thoi_gian_hoan_thanh AS THOI_GIAN_HOAN_THANH,
        h.LOAD_DATETIME AS CREATED_AT
    FROM {{ ref('hub_dv_ky_thuat') }} h
    LEFT JOIN latest_sat s ON h.DV_KY_THUAT_PK = s.DV_KY_THUAT_PK AND s.row_num = 1
)

SELECT * FROM final
