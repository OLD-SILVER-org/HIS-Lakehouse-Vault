{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg_dm_nhom_dich_vu_cap2'
src_pk: 'NHOM_DICH_VU_CAP2_PK'
src_hashdiff: 'NHOM_DICH_VU_CAP2_HASHDIFF'
src_payload:
  - 'ten'
  - 'luu_phim_chup'
  - 'phieu_chi_dinh_id'
  - 'tach_stt_noi_tru'
  - 'tach_stt_uu_tien'
  - 'theo_yeu_cau'
  - 'tiep_don_cls'
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
