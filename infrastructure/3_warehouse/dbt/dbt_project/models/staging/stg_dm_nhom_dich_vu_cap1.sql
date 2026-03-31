{%- set yaml_metadata -%}
source_model:
  staging: 'dm_nhom_dich_vu_cap1'
derived_columns:
  RECORD_SOURCE: '!POSTGRES_HOSPITAL'
  LOAD_DATETIME: 'NOW()'
hashed_columns:
  NHOM_DICH_VU_CAP1_PK: 'code_service_lvl_1'
  NHOM_DICH_VU_CAP1_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ten'
      - 'loai_dich_vu'
      - 'stt_bang_ke'
      - 'trang_thai_hoan_thanh'
      - 'trang_thai_lay_stt'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                  source_model=metadata_dict['source_model'],
                  derived_columns=metadata_dict['derived_columns'],
                  hashed_columns=metadata_dict['hashed_columns'],
                  ranked_columns=none) }}
