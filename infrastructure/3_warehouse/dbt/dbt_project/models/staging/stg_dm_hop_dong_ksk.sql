{%- set yaml_metadata -%}
source_model:
  staging: 'dm_hop_dong_ksk'
derived_columns:
  RECORD_SOURCE: '!POSTGRES_HOSPITAL'
  LOAD_DATETIME: 'NOW()'
hashed_columns:
  HOP_DONG_KSK_PK: 'id'
  HOP_DONG_KSK_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ten'
      - 'ds_ma_giam_gia_id'
      - 'hinh_thuc_mien_giam'
      - 'hinh_thuc_tt_dv_ngoai_hd'
      - 'ngay_hieu_luc'
      - 'phan_tram_mien_giam'
      - 'so_hop_dong'
      - 'thoi_gian_thanh_ly'
      - 'tien_chua_thanh_toan'
      - 'tien_da_thanh_toan'
      - 'tien_du_kien'
      - 'tien_du_kien_sau_giam'
      - 'tien_giam_gia'
      - 'tien_mien_giam_dich_vu'
      - 'tien_mien_giam_hop_dong'
      - 'tien_thuc_te'
      - 'tien_thuc_te_sau_giam'
      - 'trang_thai'
      - 'chot_thanh_toan_dv_ksk'
      - 'tien_nb_da_thanh_toan'
      - 'tien_tai_tro_nb'
      - 'nguoi_gioi_thieu_id'
      - 'nguon_nb_id'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                  source_model=metadata_dict['source_model'],
                  derived_columns=metadata_dict['derived_columns'],
                  hashed_columns=metadata_dict['hashed_columns'],
                  ranked_columns=none) }}
