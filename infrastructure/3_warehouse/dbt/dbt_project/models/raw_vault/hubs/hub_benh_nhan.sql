{{ config(materialized='incremental') }}

{%- set source_model = "stg_benh_nhan" -%}
{%- set src_pk = "BENH_NHAN_PK" -%}
{%- set src_nk = "nb_thong_tin_id" -%}
{%- set src_ldts = "LOAD_DATETIME" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.hub(src_pk=src_pk, src_nk=src_nk, src_ldts=src_ldts,
                   src_source=src_source, source_model=source_model) }}
