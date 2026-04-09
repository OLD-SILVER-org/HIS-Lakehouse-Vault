{{ config(materialized='view') }}

SELECT 
    src.*,
    k.code_khoa
FROM {{ source('staging', 'ct_dot_dieu_tri') }} src
LEFT JOIN {{ source('staging', 'dm_khoa') }} k ON src.khoa_id = k.id
