{{ config(materialized='incremental') }}

{%- set source_model = "stg_dm_nhom_dich_vu_cap2" -%}
{%- set src_pk = "LINK_CAP1_CAP2_PK" -%}
{%- set src_fk = ["NHOM_DICH_VU_CAP2_PK", "NHOM_DICH_VU_CAP1_PK"] -%}
{%- set src_ldts = "LOAD_DATETIME" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.link(src_pk=src_pk, src_fk=src_fk, src_ldts=src_ldts,
                    src_source=src_source, source_model=source_model) }}
