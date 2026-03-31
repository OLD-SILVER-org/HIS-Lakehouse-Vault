{%- set yaml_metadata -%}
source_model:
  staging: 'ct_dv_ky_thuat'
derived_columns:
  RECORD_SOURCE: '!POSTGRES_HOSPITAL'
  LOAD_DATETIME: 'NOW()'
hashed_columns:
  DV_KY_THUAT_PK: 'id'
  CHI_DINH_DICH_VU_PK: 'id'
  DOT_DIEU_TRI_PK: 'nb_dot_dieu_tri_id'
  LINK_DV_KY_THUAT_PK:
    - 'id'
    - 'nb_dot_dieu_tri_id'
  DV_KY_THUAT_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'cap_cuu'
      - 'hinh_thuc_tt_ksk'
      - 'in_phieu_chi_dinh'
      - 'ngoai_vien_id'
      - 'phieu_in_id'
      - 'phong_thuc_hien_id'
      - 'so_lan_goi'
      - 'so_phieu_id'
      - 'stt'
      - 'tam_ung'
      - 'thanh_toan_sau'
      - 'theo_yeu_cau'
      - 'thoi_gian_lay_so'
      - 'thoi_gian_tiep_nhan'
      - 'thuc_hien_tai_khoa'
      - 'trang_thai'
      - 'tu_van_vien_id'
      - 'uu_tien'
      - 'ly_do_khong_thuc_hien'
      - 'thoi_gian_xac_nhan_khong_thuc_hien'
      - 'khong_thuc_hien'
      - 'ly_doi_khong_thuc_hien'
      - 'trang_thai_thong_bao'
      - 'thoi_gian_bat_dau'
      - 'thoi_gian_hoan_thanh'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                  source_model=metadata_dict['source_model'],
                  derived_columns=metadata_dict['derived_columns'],
                  hashed_columns=metadata_dict['hashed_columns'],
                  ranked_columns=none) }}
