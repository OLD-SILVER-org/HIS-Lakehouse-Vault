{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg_dm_dv_discount'
src_pk: 'DV_DISCOUNT_PK'
src_hashdiff: 'DV_DISCOUNT_HASHDIFF'
src_payload:
  - 'discount_percent'
  - 'loai_dich_vu_id'
  - 'type_discount'
  - 'fix_amount'
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
