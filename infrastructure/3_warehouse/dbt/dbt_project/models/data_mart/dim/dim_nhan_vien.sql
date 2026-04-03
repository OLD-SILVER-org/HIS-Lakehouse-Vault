{{ config(
    materialized='table',
    schema='data_mart'
) }}

WITH latest_sat AS (
    SELECT 
        NHAN_VIEN_PK,
        ten,
        chung_chi,
        email,
        gioi_tinh,
        ngay_sinh,
        active,
        deleted,
        LOAD_DATETIME,
        ROW_NUMBER() OVER (
            PARTITION BY NHAN_VIEN_PK 
            ORDER BY LOAD_DATETIME DESC
        ) as row_num
    FROM {{ ref('sat_nhan_vien') }}
),

final AS (
    SELECT
        h.NHAN_VIEN_PK,
        h.code_nhan_vien AS MA_NHAN_VIEN,
        s.ten AS TEN_NHAN_VIEN,
        s.chung_chi AS SO_CHUNG_CHI,
        s.gioi_tinh AS GIOI_TINH,
        s.ngay_sinh AS NGAY_SINH,
        s.email AS EMAIL,
        s.active AS IS_ACTIVE,
        h.LOAD_DATETIME AS CREATED_AT,
        s.LOAD_DATETIME AS UPDATED_AT
    FROM {{ ref('hub_nhan_vien') }} h
    LEFT JOIN latest_sat s 
        ON h.NHAN_VIEN_PK = s.NHAN_VIEN_PK 
        AND s.row_num = 1
    WHERE s.deleted = 0 OR s.deleted IS NULL
)

SELECT * FROM final
