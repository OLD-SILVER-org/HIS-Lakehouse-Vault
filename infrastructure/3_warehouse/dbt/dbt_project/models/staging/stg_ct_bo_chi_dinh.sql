{%- set yaml_metadata -%}
source_model:
  staging: 'ct_bo_chi_dinh'
derived_columns:
  RECORD_SOURCE: '!POSTGRES_HOSPITAL'
  LOAD_DATETIME: 'NOW()'
hashed_columns:
  LINK_BO_CHI_DINH_PK:
    - 'nb_dot_dieu_tri_id'
    - 'bo_chi_dinh_id'
  DOT_DIEU_TRI_PK: 'nb_dot_dieu_tri_id'
  BO_CHI_DINH_PK: 'bo_chi_dinh_id'

{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                  source_model=metadata_dict['source_model'],
                  derived_columns=metadata_dict['derived_columns'],
                  hashed_columns=metadata_dict['hashed_columns'],
                  ranked_columns=none) }}
