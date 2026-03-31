{{ config(materialized='incremental') }}

{%- set source_model = "stg_ct_kham_suc_khoe" -%}
{%- set src_pk = "LINK_KHAM_SUC_KHOE_PK" -%}
{%- set src_fk = ["KHAM_SUC_KHOE_PK", "HOP_DONG_KSK_PK"] -%}
{%- set src_ldts = "LOAD_DATETIME" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.link(src_pk=src_pk, src_fk=src_fk, src_ldts=src_ldts,
                    src_source=src_source, source_model=source_model) }}
