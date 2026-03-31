{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg_dm_hop_dong_ksk'
src_pk: 'HOP_DONG_KSK_PK'
src_hashdiff: 'HOP_DONG_KSK_HASHDIFF'
src_payload:
  - 'ten'
  - 'ds_ma_giam_gia_id'
  - 'hinh_thuc_mien_giam'
  - 'hinh_thuc_tt_dv_ngoai_hd'
  - 'ngay_hieu_luc'
  - 'phan_tram_mien_giam'
  - 'so_hop_dong'
  - 'thoi_gian_thanh_ly'
  - 'tien_chua_thanh_toan'
  - 'tien_da_thanh_toan'
  - 'tien_du_kien'
  - 'tien_du_kien_sau_giam'
  - 'tien_giam_gia'
  - 'tien_mien_giam_dich_vu'
  - 'tien_mien_giam_hop_dong'
  - 'tien_thuc_te'
  - 'tien_thuc_te_sau_giam'
  - 'trang_thai'
  - 'chot_thanh_toan_dv_ksk'
  - 'tien_nb_da_thanh_toan'
  - 'tien_tai_tro_nb'
  - 'nguoi_gioi_thieu_id'
  - 'nguon_nb_id'
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
