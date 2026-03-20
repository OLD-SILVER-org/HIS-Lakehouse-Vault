{%- set yaml_metadata -%}
source_model:
  staging: 'dm_benh_nhan'
derived_columns:
  RECORD_SOURCE: '!STAGING.DM_BENH_NHAN'
  LOAD_DATE: 'updated_at'
hashed_columns:
  BENH_NHAN_PK: 'ma_nb'
  BENH_NHAN_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'email'
      - 'ngay_sinh'
      - 'noi_lam_viec'
      - 'so_dien_thoai'
      - 'ten_nb'
      - 'ten_nb_khong_dau'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     null_columns=none,
                     hashed_columns=metadata_dict['hashed_columns'],
                     ranked_columns=none) }}
