{%- set yaml_metadata -%}
source_model: 'stg_dm_phong_prep'
derived_columns:
  RECORD_SOURCE: '!POSTGRES_HOSPITAL'
  LOAD_DATETIME: 'NOW()'
hashed_columns:
  PHONG_PK: 'code_phong'
  KHOA_PK: 'code_khoa'
  PHONG_HASHDIFF:
    is_hashdiff: true
    columns:
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

{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                  source_model=metadata_dict['source_model'],
                  derived_columns=metadata_dict['derived_columns'],
                  hashed_columns=metadata_dict['hashed_columns'],
                  ranked_columns=none) }}
