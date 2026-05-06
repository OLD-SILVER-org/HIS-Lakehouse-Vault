{%- set yaml_metadata -%}
source_model: 'stg_dm_bo_chi_dinh'
src_pk: 'BO_CHI_DINH_PK'
src_hashdiff: 'BO_CHI_DINH_HASHDIFF'
src_payload:
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
src_eff: 'LOAD_DATETIME'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                 src_hashdiff=metadata_dict['src_hashdiff'],
                 src_payload=metadata_dict['src_payload'],
                 src_eff=metadata_dict['src_eff'],
                 src_ldts=metadata_dict['src_ldts'],
                 src_source=metadata_dict['src_source'],
                 source_model=metadata_dict['source_model']) }}
