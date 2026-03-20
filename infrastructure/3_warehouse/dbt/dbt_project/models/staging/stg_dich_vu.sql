{%- set yaml_metadata -%}
source_model:
  staging: 'dm_dich_vu'
derived_columns:
  RECORD_SOURCE: '!STAGING.DM_DICH_VU'
  LOAD_DATE: 'updated_at'
hashed_columns:
  DICH_VU_PK: 'code_dichvu'
  DICH_VU_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ten'
      - 'loai_dich_vu'
      - 'gia_bao_hiem'
      - 'gia_khong_bao_hiem'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     null_columns=none,
                     hashed_columns=metadata_dict['hashed_columns'],
                     ranked_columns=none) }}
