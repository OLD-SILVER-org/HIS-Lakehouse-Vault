{%- set yaml_metadata -%}
source_model: 'stg_phieu_thu'
src_pk: 'PHIEU_THU_PK'
src_hashdiff: 'PHIEU_THU_HASHDIFF'
src_payload:
  - 'ca_lam_viec_id'
  - 'doi_tuong_kcb'
  - 'ds_ma_giam_gia_id'
  - 'ghi_chu'
  - 'hinh_thuc_mien_giam'
  - 'hoa_don_id'
  - 'ky_hieu'
  - 'loai_phieu_thu'
  - 'nb_goi_dv_id'
  - 'nha_thu_ngan_id'
  - 'nho_hon_muc_cung_chi_tra'
  - 'phan_tram_mien_giam'
  - 'quay_id'
  - 'so_phieu'
  - 'thanh_tien'
  - 'thanh_toan'
  - 'thoi_gian_huy_thanh_toan'
  - 'thoi_gian_thanh_toan'
  - 'tien_bh_thanh_toan'
  - 'tien_bh_thanh_toan_trong_goi'
  - 'tien_giam_gia'
  - 'tien_hoan_tra'
  - 'tien_mien_giam_dich_vu'
  - 'tien_mien_giam_phieu_thu'
  - 'tien_nb_cung_chi_tra'
  - 'tien_nb_phu_thu'
  - 'tien_nb_tu_tra'
  - 'tien_nguon_khac'
  - 'trang_thai_hoa_don'
  - 'hoan_ung'
  - 'thoi_gian_tao_phieu'
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
