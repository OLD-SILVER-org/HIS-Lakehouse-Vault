{%- set yaml_metadata -%}
source_model: 'stg_ct_dich_vu'
src_pk: 'LINK_CHI_DINH_DICH_VU_PK'
src_hashdiff: 'CHI_DINH_DV_HASHDIFF'
src_payload:
  - 'doi_tuong_kcb'
  - 'ghi_chu'
  - 'gia_bao_hiem'
  - 'gia_goc'
  - 'gia_khong_bao_hiem'
  - 'so_luong'
  - 'thoi_gian_chi_dinh'
  - 'tien_bh_thanh_toan'
  - 'tien_nb_cung_chi_tra'
  - 'tien_nb_tu_tra'
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
