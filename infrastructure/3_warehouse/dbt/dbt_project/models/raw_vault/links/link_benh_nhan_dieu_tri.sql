{{ config(materialized='incremental') }}

{%- set source_model = "stg_dot_dieu_tri" -%}
{%- set src_pk = "LINK_BENH_NHAN_DIEU_TRI_PK" -%}
{%- set src_fk = ["BENH_NHAN_PK", "DOT_DIEU_TRI_PK"] -%}
{%- set src_ldts = "LOAD_DATETIME" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.link(src_pk=src_pk, src_fk=src_fk, src_ldts=src_ldts,
                    src_source=src_source, source_model=source_model) }}
