{%- set yaml_metadata -%}
source_model: 'stg_dich_vu'
src_pk: 'DICH_VU_PK'
src_hashdiff: 'DICH_VU_HASHDIFF'
src_payload:
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
