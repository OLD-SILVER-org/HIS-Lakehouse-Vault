{{ config(
    materialized='table',
    schema='data_mart'
) }}

WITH latest_sat AS (
    SELECT 
        BO_CHI_DINH_PK,
        ten,
        active,
        deleted,
        ROW_NUMBER() OVER (PARTITION BY BO_CHI_DINH_PK ORDER BY LOAD_DATETIME DESC) as row_num
    FROM {{ ref('sat_bo_chi_dinh') }}
),

final AS (
    SELECT
        h.BO_CHI_DINH_PK,
        h.id AS BO_CHI_DINH_ID,
        s.ten AS TEN_BO_CHI_DINH,
        s.active AS IS_ACTIVE,
        h.LOAD_DATETIME AS CREATED_AT
    FROM {{ ref('hub_bo_chi_dinh') }} h
    LEFT JOIN latest_sat s ON h.BO_CHI_DINH_PK = s.BO_CHI_DINH_PK AND s.row_num = 1
    WHERE s.deleted = 0 OR s.deleted IS NULL
)

SELECT * FROM final
