{{ config(materialized='view') }}

SELECT 
    src.*,
    k.code_khoa,
    nv.code_nhan_vien AS code_nhan_vien_kham,
    dv.code_dichvu
FROM {{ source('staging', 'ct_dich_vu') }} src
LEFT JOIN {{ source('staging', 'dm_khoa') }} k ON src.khoa_chi_dinh_id = k.id
LEFT JOIN {{ source('staging', 'dm_nhan_vien') }} nv ON src.bac_si_chi_dinh_id = nv.id
LEFT JOIN {{ source('staging', 'dm_dich_vu') }} dv ON src.dich_vu_id = dv.id
