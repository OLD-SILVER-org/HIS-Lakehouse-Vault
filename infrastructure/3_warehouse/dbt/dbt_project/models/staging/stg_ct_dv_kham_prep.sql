{{ config(materialized='view') }}

SELECT 
    src.*,
    nv_kham.code_nhan_vien AS code_nhan_vien_kham,
    nv_kl.code_nhan_vien AS code_nhan_vien_kl
FROM {{ source('staging', 'ct_dv_kham') }} src
LEFT JOIN {{ source('staging', 'dm_nhan_vien') }} nv_kham ON src.bac_si_kham_id = nv_kham.id
LEFT JOIN {{ source('staging', 'dm_nhan_vien') }} nv_kl ON src.bac_si_ket_luan_id = nv_kl.id
