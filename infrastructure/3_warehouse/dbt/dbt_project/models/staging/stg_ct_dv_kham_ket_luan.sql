{%- set yaml_metadata -%}
source_model:
  staging: 'ct_dv_kham_ket_luan'
derived_columns:
  RECORD_SOURCE: '!POSTGRES_HOSPITAL'
  LOAD_DATETIME: 'NOW()'
hashed_columns:
  KHAM_KET_LUAN_PK: 'id'
  KHAM_BENH_PK: 'id'
  KHAM_KET_LUAN_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'nb_bo_chi_dinh_id'
      - 'huong_dieu_tri'
      - 'ket_qua_dieu_tri'
      - 'loi_dan'
      - 'phong_hen_kham_id'
      - 'so_ngay_cho_don'
      - 'thoi_gian_hen_tai_kham'
      - 'thoi_gian_ket_luan'
      - 'so_hen_kham'
      - 'thong_tin_theo_doi'
      - 'den_ngay'
      - 'tu_ngay'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                  source_model=metadata_dict['source_model'],
                  derived_columns=metadata_dict['derived_columns'],
                  hashed_columns=metadata_dict['hashed_columns'],
                  ranked_columns=none) }}
