{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg_ct_dv_kham_ket_luan'
src_pk: 'KHAM_BENH_PK'
src_hashdiff: 'KHAM_KET_LUAN_HASHDIFF'
src_payload:
  - 'nb_bo_chi_dinh_id'
  - 'huong_dieu_tri'
  - 'ket_qua_dieu_tri'
  - 'loi_dan'
  - 'phong_hen_kham_id'
  - 'so_ngay_cho_don'
  - 'thoi_gian_hen_tai_kham'
  - 'thoi_gian_ket_luan'
  - 'so_hen_kham'
  - 'thong_tin_theo_doi'
  - 'den_ngay'
  - 'tu_ngay'
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
