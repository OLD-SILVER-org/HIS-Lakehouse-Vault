{{ config(
    materialized='table',
    schema='data_mart'
) }}

WITH latest_sat AS (
    SELECT 
        PHIEU_THU_PK,
        so_phieu,
        loai_phieu_thu,
        thanh_tien,
        thoi_gian_thanh_toan,
        trang_thai_hoa_don,
        active,
        deleted,
        ROW_NUMBER() OVER (PARTITION BY PHIEU_THU_PK ORDER BY LOAD_DATETIME DESC) as row_num
    FROM {{ ref('sat_thanh_toan') }}
),

final AS (
    SELECT
        h.PHIEU_THU_PK,
        h.id AS PHIEU_THU_ID,
        s.so_phieu AS SO_PHIEU,
        s.loai_phieu_thu AS LOAI_PHIEU_THU,
        s.thanh_tien AS TONG_TIEN,
        s.thoi_gian_thanh_toan AS THOI_GIAN_THANH_TOAN,
        s.trang_thai_hoa_don AS TRANG_THAI_HOA_DON,
        s.active AS IS_ACTIVE,
        h.LOAD_DATETIME AS CREATED_AT
    FROM {{ ref('hub_phieu_thu') }} h
    LEFT JOIN latest_sat s ON h.PHIEU_THU_PK = s.PHIEU_THU_PK AND s.row_num = 1
    WHERE s.deleted = 0 OR s.deleted IS NULL
)

SELECT * FROM final
