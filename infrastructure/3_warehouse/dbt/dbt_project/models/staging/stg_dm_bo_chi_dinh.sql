{%- set yaml_metadata -%}
source_model:
  staging: 'dm_bo_chi_dinh'
derived_columns:
  RECORD_SOURCE: '!POSTGRES_HOSPITAL'
  LOAD_DATETIME: 'NOW()'
hashed_columns:
  BO_CHI_DINH_PK: 'id'
  BO_CHI_DINH_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'code_bo_chi_dinh'
      - 'ten'
      - 'ds_bac_si_chi_dinh_id'
      - 'ds_doi_tuong_su_dung'
      - 'ds_kho_id'
      - 'ds_loai_dich_vu'
      - 'han_che_khoa_chi_dinh'
      - 'hop_dong_ksk_id'
      - 'thuoc_chi_dinh_ngoai'
      - 'ket_qua_lau'
      - 'active'
      - 'deleted'

{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                  source_model=metadata_dict['source_model'],
                  derived_columns=metadata_dict['derived_columns'],
                  hashed_columns=metadata_dict['hashed_columns'],
                  ranked_columns=none) }}
