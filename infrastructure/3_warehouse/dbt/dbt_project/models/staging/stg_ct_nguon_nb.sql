{%- set yaml_metadata -%}
source_model:
  staging: 'ct_nguon_nb'
derived_columns:
  RECORD_SOURCE: '!POSTGRES_HOSPITAL'
  LOAD_DATETIME: 'NOW()'
hashed_columns:
  CT_NGUON_NB_PK: 'nb_dot_dieu_tri_id'
  DOT_DIEU_TRI_PK: 'nb_dot_dieu_tri_id'
  NGUON_NB_PK: 'nguon_nb_id'
  NGUOI_GIOI_THIEU_PK: 'nguoi_gioi_thieu_id'
  CT_NGUON_NB_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ghi_chu'
      - 'nguoi_gioi_thieu_id'
      - 'nguon_nb_id'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                  source_model=metadata_dict['source_model'],
                  derived_columns=metadata_dict['derived_columns'],
                  hashed_columns=metadata_dict['hashed_columns'],
                  ranked_columns=none) }}
