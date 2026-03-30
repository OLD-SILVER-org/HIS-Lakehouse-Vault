{%- set yaml_metadata -%}
source_model:
  staging: 'dm_dich_vu'
derived_columns:
  RECORD_SOURCE: '!POSTGRES_HOSPITAL'
  LOAD_DATETIME: 'NOW()'
hashed_columns:
  DICH_VU_PK: 'code_dichvu'
  DICH_VU_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ten'
      - 'don_vi_tinh_id'
      - 'ds_nguon_khac_chi_tra'
      - 'gia_bao_hiem'
      - 'gia_khong_bao_hiem'
      - 'khong_tinh_tien'
      - 'loai_dich_vu'
      - 'nhom_dich_vu_cap1_id'
      - 'nhom_dich_vu_cap2_id'
      - 'nhom_dich_vu_cap3_id'
      - 'ten_tuong_duong'
      - 'thu_ngoai'
      - 'ty_le_bh_tt'
      - 'ty_le_tt_dv'
      - 'viet_tat'
      - 'chi_dinh_sl_le'
      - 'nguon_khac_id'
      - 'gui_vitimes'
      - 'mien_phi_giam_doc_duyet'
      - 'khong_su_dung'
      - 'online_'
      - 'sua_gia'
      - 'active'
      - 'deleted'

{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                  source_model=metadata_dict['source_model'],
                  derived_columns=metadata_dict['derived_columns'],
                  hashed_columns=metadata_dict['hashed_columns'],
                  ranked_columns=metadata_dict['ranked_columns']) }}
