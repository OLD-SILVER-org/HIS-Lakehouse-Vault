{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg_dm_nhom_dich_vu_cap1'
src_pk: 'NHOM_DICH_VU_CAP1_PK'
src_hashdiff: 'NHOM_DICH_VU_CAP1_HASHDIFF'
src_payload:
  - 'ten'
  - 'loai_dich_vu'
  - 'stt_bang_ke'
  - 'trang_thai_hoan_thanh'
  - 'trang_thai_lay_stt'
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
