{%- set yaml_metadata -%}
source_model:
  staging: 'dm_nhom_dich_vu_cap3'
derived_columns:
  RECORD_SOURCE: '!POSTGRES_HOSPITAL'
  LOAD_DATETIME: 'NOW()'
hashed_columns:
  NHOM_DICH_VU_CAP3_PK: 'code_service_lvl_3'
  NHOM_DICH_VU_CAP2_PK: 'nhom_dich_vu_cap2_id'
  LINK_CAP2_CAP3_PK:
    - 'code_service_lvl_3'
    - 'nhom_dich_vu_cap2_id'
  NHOM_DICH_VU_CAP3_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ten'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                  source_model=metadata_dict['source_model'],
                  derived_columns=metadata_dict['derived_columns'],
                  hashed_columns=metadata_dict['hashed_columns'],
                  ranked_columns=none) }}
