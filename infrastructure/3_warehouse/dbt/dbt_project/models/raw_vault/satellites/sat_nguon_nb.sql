{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg_ct_nguon_nb'
src_pk: 'LINK_NGUON_NB_PK'
src_hashdiff: 'CT_NGUON_NB_HASHDIFF'
src_payload:
  - 'ghi_chu'
  - 'nguoi_gioi_thieu_id'
  - 'nguon_nb_id'
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
