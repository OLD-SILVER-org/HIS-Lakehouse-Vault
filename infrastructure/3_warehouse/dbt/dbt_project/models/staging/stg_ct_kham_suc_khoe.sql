{%- set yaml_metadata -%}
source_model:
  staging: 'ct_kham_suc_khoe'
derived_columns:
  RECORD_SOURCE: '!POSTGRES_HOSPITAL'
  LOAD_DATETIME: 'NOW()'
hashed_columns:
  KHAM_SUC_KHOE_PK: 'id'
  HOP_DONG_KSK_PK: 'hop_dong_ksk_id'
  KHAM_SUC_KHOE_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'chuc_vu'
      - 'den_thoi_gian_kham'
      - 'den_thoi_gian_lay_mau'
      - 'dia_diem_kham'
      - 'dia_diem_lay_mau'
      - 'ds_bo_chi_dinh_id'
      - 'ds_dich_vu_id'
      - 'hinh_thuc_tt_dv_ngoai_hd'
      - 'ma_nhan_vien'
      - 'ngoai_vien'
      - 'phong_ban'
      - 'stt'
      - 'thoi_gian_hoan_thanh'
      - 'trang_thai'
      - 'tu_thoi_gian_kham'
      - 'tu_thoi_gian_lay_mau'
      - 'hinh_thuc_tt_dv_trong_hd'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                  source_model=metadata_dict['source_model'],
                  derived_columns=metadata_dict['derived_columns'],
                  hashed_columns=metadata_dict['hashed_columns'],
                  ranked_columns=none) }}
