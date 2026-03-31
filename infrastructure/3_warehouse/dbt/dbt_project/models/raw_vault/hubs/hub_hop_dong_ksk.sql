{{ config(materialized='incremental') }}

{%- set source_model = "stg_dm_hop_dong_ksk" -%}
{%- set src_pk = "HOP_DONG_KSK_PK" -%}
{%- set src_nk = "code_hop_dong" -%}
{%- set src_ldts = "LOAD_DATETIME" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.hub(src_pk=src_pk, src_nk=src_nk, src_ldts=src_ldts,
                   src_source=src_source, source_model=source_model) }}
