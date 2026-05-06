{%- set yaml_metadata -%}
source_model:
  staging: 'dm_nhan_vien'
derived_columns:
  RECORD_SOURCE: '!POSTGRES_HOSPITAL'
  LOAD_DATETIME: 'NOW()'
hashed_columns:
  NHAN_VIEN_PK: 'code_nhan_vien'
  NHAN_VIEN_HASHDIFF:
    is_hashdiff: true
    columns:
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

{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                  source_model=metadata_dict['source_model'],
                  derived_columns=metadata_dict['derived_columns'],
                  hashed_columns=metadata_dict['hashed_columns'],
                  ranked_columns=metadata_dict['ranked_columns']) }}
