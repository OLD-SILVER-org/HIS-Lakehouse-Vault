{{ config(materialized='view') }}

SELECT 
    src.*,
    k.code_khoa
FROM {{ source('staging', 'dm_phong') }} src
LEFT JOIN {{ source('staging', 'dm_khoa') }} k ON src.khoa_id = k.id
