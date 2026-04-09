{%- set yaml_metadata -%}
source_model: 'stg_ct_phieu_thu_prep'
derived_columns:
  RECORD_SOURCE: '!POSTGRES_HOSPITAL'
  LOAD_DATETIME: 'NOW()'
hashed_columns:
  PHIEU_THU_PK: 'id'
  DOT_DIEU_TRI_PK: 'nb_dot_dieu_tri_id'
  NHAN_VIEN_THU_NGAN_PK: 'code_thu_ngan'
  LINK_THANH_TOAN_PK:
    - 'id'
    - 'nb_dot_dieu_tri_id'
    - 'code_thu_ngan'
  PHIEU_THU_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'active'
      - 'deleted'
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
      - 'thu_ngan_huy_thanh_toan_id'
      - 'thu_ngan_id'
      - 'tien_bh_thanh_toan'
      - 'tien_bh_thanh_toan_trong_goi'
      - 'tien_giam_gia'
      - 'tien_hoan_tra'
      - 'tien_mien_giam_dich_vu'
      - 'tien_mien_giam_phieu_thu'
      - 'tien_mien_giam_phieu_thu_nhap_vao'
      - 'tien_nb_cung_chi_tra'
      - 'tien_nb_cung_chi_tra_trong_goi'
      - 'tien_nb_phu_thu'
      - 'tien_nb_tu_tra'
      - 'tien_nguon_khac'
      - 'tien_tai_tro_bao_hiem'
      - 'tien_tai_tro_khong_bao_hiem'
      - 'trang_thai_hoa_don'
      - 'hoan_ung'
      - 'loai_mien_giam'
      - 'phieu_doi_tra_id'
      - 'thoi_gian_tao_phieu'
      - 'thoi_gian_cap_nhat_phieu'

{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                  source_model=metadata_dict['source_model'],
                  derived_columns=metadata_dict['derived_columns'],
                  hashed_columns=metadata_dict['hashed_columns'],
                  ranked_columns=none) }}
