{{ config(materialized='incremental') }}

{%- set source_model = "stg_phieu_thu" -%}
{%- set src_pk = "LINK_THANH_TOAN_PK" -%}
{%- set src_fk = ["PHIEU_THU_PK", "DOT_DIEU_TRI_PK", "NHAN_VIEN_THU_NGAN_PK"] -%}
{%- set src_ldts = "LOAD_DATETIME" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.link(src_pk=src_pk, src_fk=src_fk, src_ldts=src_ldts,
                    src_source=src_source, source_model=source_model) }}
