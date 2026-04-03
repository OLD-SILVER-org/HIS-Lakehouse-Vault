{{ config(
    materialized='table',
    schema='data_mart'
) }}

WITH latest_sat_khoa AS (
    SELECT 
        KHOA_PK,
        ten,
        active,
        deleted,
        ROW_NUMBER() OVER (PARTITION BY KHOA_PK ORDER BY LOAD_DATETIME DESC) as row_num
    FROM {{ ref('sat_khoa') }}
),

latest_sat_phong AS (
    SELECT 
        PHONG_PK,
        ten,
        active,
        deleted,
        ROW_NUMBER() OVER (PARTITION BY PHONG_PK ORDER BY LOAD_DATETIME DESC) as row_num
    FROM {{ ref('sat_phong') }}
),

union_final AS (
    -- Dữ liệu Khoa
    SELECT
        h.KHOA_PK AS DON_VI_PK,
        h.code_khoa AS MA_DON_VI,
        s.ten AS TEN_DON_VI,
        'KHOA' AS LOAI_DON_VI,
        s.active AS IS_ACTIVE,
        h.LOAD_DATETIME AS CREATED_AT
    FROM {{ ref('hub_khoa') }} h
    LEFT JOIN latest_sat_khoa s ON h.KHOA_PK = s.KHOA_PK AND s.row_num = 1
    WHERE s.deleted = 0 OR s.deleted IS NULL

    UNION ALL

    -- Dữ liệu Phòng
    SELECT
        h.PHONG_PK AS DON_VI_PK,
        h.code_phong AS MA_DON_VI,
        s.ten AS TEN_DON_VI,
        'PHONG' AS LOAI_DON_VI,
        s.active AS IS_ACTIVE,
        h.LOAD_DATETIME AS CREATED_AT
    FROM {{ ref('hub_phong') }} h
    LEFT JOIN latest_sat_phong s ON h.PHONG_PK = s.PHONG_PK AND s.row_num = 1
    WHERE s.deleted = 0 OR s.deleted IS NULL
)

SELECT * FROM union_final
