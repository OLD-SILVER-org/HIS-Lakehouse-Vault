{%- set yaml_metadata -%}
source_model: 'stg_ct_dv_kham_prep'
derived_columns:
  RECORD_SOURCE: '!POSTGRES_HOSPITAL'
  LOAD_DATETIME: 'NOW()'
hashed_columns:
  KHAM_BENH_PK: 'id'
  DOT_DIEU_TRI_PK: 'nb_dot_dieu_tri_id'
  NHAN_VIEN_KHAM_PK: 'code_nhan_vien_kham'
  NHAN_VIEN_KL_PK: 'code_nhan_vien_kl'
  LINK_KHAM_BENH_PK:
    - 'nb_dot_dieu_tri_id'
    - 'code_nhan_vien_kham'
  KHAM_BENH_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'dot_kham_moi'
      - 'nguoi_phien_dich_id'
      - 'stt_chuyen_khoa'
      - 'thiet_lap'
      - 'thoi_gian_kham'
      - 'thoi_gian_ket_luan'
      - 'active'
      - 'deleted'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                  source_model=metadata_dict['source_model'],
                  derived_columns=metadata_dict['derived_columns'],
                  hashed_columns=metadata_dict['hashed_columns'],
                  ranked_columns=none) }}
