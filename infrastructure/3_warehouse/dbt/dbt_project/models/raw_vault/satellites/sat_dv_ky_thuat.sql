{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg_ct_dv_ky_thuat'
src_pk: 'DV_KY_THUAT_PK'
src_hashdiff: 'DV_KY_THUAT_HASHDIFF'
src_payload:
  - 'cap_cuu'
  - 'hinh_thuc_tt_ksk'
  - 'in_phieu_chi_dinh'
  - 'ngoai_vien_id'
  - 'phieu_in_id'
  - 'phong_thuc_hien_id'
  - 'so_lan_goi'
  - 'so_phieu_id'
  - 'stt'
  - 'tam_ung'
  - 'thanh_toan_sau'
  - 'theo_yeu_cau'
  - 'thoi_gian_lay_so'
  - 'thoi_gian_tiep_nhan'
  - 'thuc_hien_tai_khoa'
  - 'trang_thai'
  - 'tu_van_vien_id'
  - 'uu_tien'
  - 'ly_do_khong_thuc_hien'
  - 'thoi_gian_xac_nhan_khong_thuc_hien'
  - 'khong_thuc_hien'
  - 'ly_doi_khong_thuc_hien'
  - 'trang_thai_thong_bao'
  - 'thoi_gian_bat_dau'
  - 'thoi_gian_hoan_thanh'
src_eff: 'LOAD_DATETIME'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                 src_hashdiff=metadata_dict['src_hashdiff'],
                 src_payload=metadata_dict['src_payload'],
                 src_eff=metadata_dict['src_eff'],
                 src_ldts=metadata_dict['src_ldts'],
                 src_source=metadata_dict['src_source'],
                 source_model=metadata_dict['source_model']) }}
