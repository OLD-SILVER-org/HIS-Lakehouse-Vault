{{ config(materialized='incremental') }}

{%- set source_model = "stg_ct_dich_vu" -%}
{%- set src_pk = "LINK_CHI_DINH_DICH_VU_PK" -%}
{%- set src_fk = ["DOT_DIEU_TRI_PK", "DICH_VU_PK", "NHAN_VIEN_PK", "KHOA_PK"] -%}
{%- set src_ldts = "LOAD_DATETIME" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.link(src_pk=src_pk, src_fk=src_fk, src_ldts=src_ldts,
                    src_source=src_source, source_model=source_model) }}
