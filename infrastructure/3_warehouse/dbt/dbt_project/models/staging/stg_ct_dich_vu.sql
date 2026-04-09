{%- set yaml_metadata -%}
source_model: 'stg_ct_dich_vu_prep'
derived_columns:
  RECORD_SOURCE: '!POSTGRES_HOSPITAL'
  LOAD_DATETIME: 'NOW()'
hashed_columns:
  CHI_DINH_DV_PK: 'id'
  DOT_DIEU_TRI_PK: 'nb_dot_dieu_tri_id'
  DICH_VU_PK: 'code_dichvu'
  NHAN_VIEN_PK: 'code_nhan_vien_kham'
  KHOA_PK: 'code_khoa'
  LINK_CHI_DINH_DICH_VU_PK:
    - 'nb_dot_dieu_tri_id'
    - 'code_dichvu'
    - 'code_nhan_vien_kham'
    - 'code_khoa'
  CHI_DINH_DV_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'chi_dinh_tu_dich_vu_id'
      - 'doi_tuong_kcb'
      - 'dung_tuyen'
      - 'ghi_chu'
      - 'gia_bao_hiem'
      - 'gia_goc'
      - 'gia_khong_bao_hiem'
      - 'loai_dich_vu'
      - 'loai_hinh_thanh_toan_id'
      - 'nb_goi_dv_chi_tiet_id'
      - 'nb_the_bao_hiem_id'
      - 'ngoai_vien'
      - 'phat_hanh_hoa_don'
      - 'phieu_thu_id'
      - 'so_luong'
      - 'thanh_toan'
      - 'thoi_gian_chi_dinh'
      - 'thoi_gian_thuc_hien'
      - 'tien_bh_thanh_toan'
      - 'tien_giam_gia_bh'
      - 'tien_giam_gia_khong_bh'
      - 'tien_mien_giam_dich_vu_bh'
      - 'tien_mien_giam_dich_vu_khong_bh'
      - 'tien_mien_giam_phieu_thu_bh'
      - 'tien_mien_giam_phieu_thu_khong_bh'
      - 'tien_nb_cung_chi_tra'
      - 'tien_nb_phu_thu'
      - 'tien_nb_tu_tra'
      - 'tien_nguon_khac'
      - 'trang_thai_hoan'
      - 'tu_tra'
      - 'active'
      - 'deleted'

{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                  source_model=metadata_dict['source_model'],
                  derived_columns=metadata_dict['derived_columns'],
                  hashed_columns=metadata_dict['hashed_columns'],
                  ranked_columns=none) }}
