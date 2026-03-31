{{ config(materialized='incremental') }}

{%- set source_model = "stg_ct_dv_ky_thuat" -%}
{%- set src_pk = "LINK_DV_KY_THUAT_PK" -%}
{%- set src_fk = ["DV_KY_THUAT_PK", "DOT_DIEU_TRI_PK"] -%}
{%- set src_ldts = "LOAD_DATETIME" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.link(src_pk=src_pk, src_fk=src_fk, src_ldts=src_ldts,
                    src_source=src_source, source_model=source_model) }}
