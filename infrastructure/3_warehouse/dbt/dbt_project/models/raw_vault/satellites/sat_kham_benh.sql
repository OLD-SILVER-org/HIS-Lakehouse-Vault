{%- set yaml_metadata -%}
source_model: 'stg_dv_kham'
src_pk: 'LINK_KHAM_BENH_PK'
src_hashdiff: 'KHAM_BENH_HASHDIFF'
src_payload:
  - 'dot_kham_moi'
  - 'thoi_gian_kham'
  - 'thoi_gian_ket_luan'
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
