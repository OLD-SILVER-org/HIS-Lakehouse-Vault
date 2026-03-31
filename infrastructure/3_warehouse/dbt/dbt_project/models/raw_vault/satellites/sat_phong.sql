{%- set yaml_metadata -%}
source_model: 'stg_phong'
src_pk: 'PHONG_PK'
src_hashdiff: 'PHONG_HASHDIFF'
src_payload:
  - 'ten'
  - 'chuyen_khoa_id'
  - 'dia_diem'
  - 'ds_loai_phong'
  - 'khoa_id'
  - 'ngoai_tru'
  - 'ngoai_vien'
  - 'noi_tru'
  - 'online'
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
