{{ config(materialized='incremental') }}

{%- set source_model = "stg_phieu_thu" -%}
{%- set src_pk = "PHIEU_THU_PK" -%}
{%- set src_nk = "id" -%}
{%- set src_ldts = "LOAD_DATETIME" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.hub(src_pk=src_pk, src_nk=src_nk, src_ldts=src_ldts,
                   src_source=src_source, source_model=source_model) }}
