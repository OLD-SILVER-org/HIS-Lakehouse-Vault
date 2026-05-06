{%- set yaml_metadata -%}
source_model: 'stg_dm_benh_nhan'
src_pk: 'BENH_NHAN_PK'
src_hashdiff: 'BENH_NHAN_HASHDIFF'
src_payload:
  - 'nb_thong_tin_id'
  - 'email'
  - 'ngay_sinh'
  - 'noi_lam_viec'
  - 'so_dien_thoai'
  - 'ten_nb'
  - 'ten_nb_khong_dau'
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
