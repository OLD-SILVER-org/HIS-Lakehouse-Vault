{%- set yaml_metadata -%}
source_model:
  staging: 'dm_nhom_dich_vu_cap2'
derived_columns:
  RECORD_SOURCE: '!POSTGRES_HOSPITAL'
  LOAD_DATETIME: 'NOW()'
hashed_columns:
  NHOM_DICH_VU_CAP2_PK: 'code_service_lvl_2'
  NHOM_DICH_VU_CAP1_PK: 'nhom_dich_vu_cap1_id'
  LINK_CAP1_CAP2_PK:
    - 'code_service_lvl_2'
    - 'nhom_dich_vu_cap1_id'
  NHOM_DICH_VU_CAP2_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ten'
      - 'luu_phim_chup'
      - 'phieu_chi_dinh_id'
      - 'tach_stt_noi_tru'
      - 'tach_stt_uu_tien'
      - 'theo_yeu_cau'
      - 'tiep_don_cls'
      - 'trang_thai_hoan_thanh'
      - 'trang_thai_lay_stt'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                  source_model=metadata_dict['source_model'],
                  derived_columns=metadata_dict['derived_columns'],
                  hashed_columns=metadata_dict['hashed_columns'],
                  ranked_columns=none) }}
