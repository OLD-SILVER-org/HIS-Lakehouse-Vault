{%- set yaml_metadata -%}
source_model:
  staging: 'dm_benh_nhan'
derived_columns:
  RECORD_SOURCE: '!POSTGRES_HOSPITAL'
  LOAD_DATETIME: 'NOW()'
hashed_columns:
  BENH_NHAN_PK: 'nb_thong_tin_id'
  BENH_NHAN_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'nb_thong_tin_id'
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
                  hashed_columns=metadata_dict['hashed_columns'],
                  ranked_columns=metadata_dict['ranked_columns']) }}
