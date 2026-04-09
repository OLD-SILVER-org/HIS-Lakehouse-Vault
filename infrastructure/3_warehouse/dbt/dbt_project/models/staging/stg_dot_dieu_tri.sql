{%- set yaml_metadata -%}
source_model: 'stg_ct_dot_dieu_tri_prep'
derived_columns:
  RECORD_SOURCE: '!POSTGRES_HOSPITAL'
  LOAD_DATETIME: 'NOW()'
hashed_columns:
  DOT_DIEU_TRI_PK: 'id'
  BENH_NHAN_PK: 'ma_nb'
  KHOA_PK: 'code_khoa'
  LINK_BENH_NHAN_DIEU_TRI_PK:
    - 'ma_nb'
    - 'id'
  LINK_DOT_DIEU_TRI_KHOA_PK:
    - 'id'
    - 'code_khoa'
  DOT_DIEU_TRI_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'cap_cuu'
      - 'chi_nam_sinh'
      - 'dan_toc_id'
      - 'doi_tuong'
      - 'doi_tuong_kcb'
      - 'email'
      - 'gioi_tinh'
      - 'kham_suc_khoe'
      - 'khoa_tiep_don_id'
      - 'loai_benh_an_id'
      - 'loai_doi_tuong_id'
      - 'ma_benh_an'
      - 'ma_ho_so'
      - 'mac_dinh'
      - 'nb_thong_tin_id'
      - 'ngay_sinh'
      - 'nghe_nghiep_id'
      - 'ngoai_vien'
      - 'nguoi_lap_benh_an_id'
      - 'nhom_mau'
      - 'noi_lam_viec'
      - 'phan_loai_nb_id'
      - 'quoc_tich_id'
      - 'so_bao_hiem_xa_hoi'
      - 'so_dien_thoai'
      - 'so_ngay_dieu_tri'
      - 'so_phoi'
      - 'ten_nb'
      - 'ten_nb_khong_dau'
      - 'thoi_gian_lap_benh_an'
      - 'thoi_gian_ra_vien'
      - 'thoi_gian_vao_vien'
      - 'tiem_chung'
      - 'trang_thai'
      - 'uu_tien'
      - 'duyet_chi_phi'
      - 'bang_lai_xe_id'
      - 'ma_doi_tuong_kcb_id'
      - 'nhan_vien_kinh_doanh_id'
      - 'can_nang_vao_vien'
      - 'cong_ty_bao_hiem_id'
      - 'phan_loai_doi_tuong'
      - 'nguoi_duyet_chi_phi_id'
      - 'nguoi_gui_duyet_chi_phi_id'
      - 'nguoi_tu_choi_duyet_chi_phi_id'
      - 'loai_lien_ket'
      - 'nb_lien_ket_id'
      - 'ho_ngheo'
      - 'active'
      - 'deleted'

{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                  source_model=metadata_dict['source_model'],
                  derived_columns=metadata_dict['derived_columns'],
                  hashed_columns=metadata_dict['hashed_columns'],
                  ranked_columns=none) }}
