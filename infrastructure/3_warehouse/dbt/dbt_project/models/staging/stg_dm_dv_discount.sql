{%- set yaml_metadata -%}
source_model:
  staging: 'dm_dv_discount'
derived_columns:
  RECORD_SOURCE: '!POSTGRES_HOSPITAL'
  LOAD_DATETIME: 'NOW()'
hashed_columns:
  DV_DISCOUNT_PK: 'id'
  DV_DISCOUNT_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'discount_percent'
      - 'loai_dich_vu_id'
      - 'type_discount'
      - 'fix_amount'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                  source_model=metadata_dict['source_model'],
                  derived_columns=metadata_dict['derived_columns'],
                  hashed_columns=metadata_dict['hashed_columns'],
                  ranked_columns=none) }}
