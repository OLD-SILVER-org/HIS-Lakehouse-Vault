{{ config(materialized='incremental') }}

{%- set source_model = "stg_dm_dv_discount" -%}
{%- set src_pk = "DV_DISCOUNT_PK" -%}
{%- set src_nk = "id" -%}
{%- set src_ldts = "LOAD_DATETIME" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.hub(src_pk=src_pk, src_nk=src_nk, src_ldts=src_ldts,
                   src_source=src_source, source_model=source_model) }}
