{{ config(materialized='view') }}

SELECT 
    src.*,
    nv.code_nhan_vien AS code_thu_ngan
FROM {{ source('staging', 'ct_phieu_thu') }} src
LEFT JOIN {{ source('staging', 'dm_nhan_vien') }} nv ON src.thu_ngan_id = nv.id
