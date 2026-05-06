{%- set yaml_metadata -%}
source_model: 'stg_dm_nhan_vien'
src_pk: 'NHAN_VIEN_PK'
src_hashdiff: 'NHAN_VIEN_HASHDIFF'
src_payload:
  - 'ten'
  - 'chung_chi'
  - 'ds_chuyen_khoa_id'
  - 'email'
  - 'gioi_tinh'
  - 'hoc_ham_hoc_vi_id'
  - 'ngay_sinh'
  - 'van_bang_id'
  - 'active'
  - 'deleted'
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
