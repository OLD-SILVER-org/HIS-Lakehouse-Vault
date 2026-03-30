{{ config(materialized='incremental') }}

{%- set source_model = "stg_nhan_vien" -%}
{%- set src_pk = "NHAN_VIEN_PK" -%}
{%- set src_nk = "code_nhan_vien" -%}
{%- set src_ldts = "LOAD_DATETIME" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.hub(src_pk=src_pk, src_nk=src_nk, src_ldts=src_ldts,
                   src_source=src_source, source_model=source_model) }}
