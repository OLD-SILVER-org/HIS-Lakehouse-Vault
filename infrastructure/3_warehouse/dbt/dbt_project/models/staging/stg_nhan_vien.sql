{%- set yaml_metadata -%}
source_model:
  staging: 'dm_nhan_vien'
derived_columns:
  RECORD_SOURCE: '!STAGING.DM_NHAN_VIEN'
  LOAD_DATE: 'updated_at'
hashed_columns:
  NHAN_VIEN_PK: 'code_nhan_vien'
  NHAN_VIEN_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ten'
      - 'email'
      - 'gioi_tinh'
      - 'ngay_sinh'
      - 'chung_chi'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     null_columns=none,
                     hashed_columns=metadata_dict['hashed_columns'],
                     ranked_columns=none) }}
