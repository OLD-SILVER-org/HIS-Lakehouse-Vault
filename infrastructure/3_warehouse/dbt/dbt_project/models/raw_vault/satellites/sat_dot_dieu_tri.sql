{%- set yaml_metadata -%}
source_model: 'stg_dot_dieu_tri'
src_pk: 'DOT_DIEU_TRI_PK'
src_hashdiff: 'DOT_DIEU_TRI_HASHDIFF'
src_payload:
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
