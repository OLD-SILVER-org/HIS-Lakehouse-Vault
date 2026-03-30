{%- set yaml_metadata -%}
source_model:
  staging: 'dm_khoa'
derived_columns:
  RECORD_SOURCE: '!POSTGRES_HOSPITAL'
  LOAD_DATETIME: 'NOW()'
hashed_columns:
  KHOA_PK: 'code_khoa'
  KHOA_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ten'
      - 'ds_tinh_chat_khoa'
      - 'active'
      - 'deleted'

{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                  source_model=metadata_dict['source_model'],
                  derived_columns=metadata_dict['derived_columns'],
                  hashed_columns=metadata_dict['hashed_columns'],
                  ranked_columns=metadata_dict['ranked_columns']) }}
