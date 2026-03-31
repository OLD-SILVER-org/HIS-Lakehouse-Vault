{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg_ct_kham_suc_khoe'
src_pk: 'KHAM_SUC_KHOE_PK'
src_hashdiff: 'KHAM_SUC_KHOE_HASHDIFF'
src_payload:
  - 'chuc_vu'
  - 'den_thoi_gian_kham'
  - 'den_thoi_gian_lay_mau'
  - 'dia_diem_kham'
  - 'dia_diem_lay_mau'
  - 'ds_bo_chi_dinh_id'
  - 'ds_dich_vu_id'
  - 'hinh_thuc_tt_dv_ngoai_hd'
  - 'ma_nhan_vien'
  - 'ngoai_vien'
  - 'phong_ban'
  - 'stt'
  - 'thoi_gian_hoan_thanh'
  - 'trang_thai'
  - 'tu_thoi_gian_kham'
  - 'tu_thoi_gian_lay_mau'
  - 'hinh_thuc_tt_dv_trong_hd'
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
