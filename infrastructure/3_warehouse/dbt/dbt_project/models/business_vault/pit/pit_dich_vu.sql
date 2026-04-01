{{ config(materialized='pit_incremental') }}

{%- set source_model = 'hub_dich_vu' -%}
{%- set src_pk = 'DICH_VU_PK' -%}
{%- set as_of_dates_table = 'as_of_dates' -%}
{%- set src_ldts = 'LOAD_DATETIME' -%}

{%- set satellites = {
    "sat_dich_vu": {
        "pk": {"PK": "DICH_VU_PK"},
        "ldts": {"LDTS": "LOAD_DATETIME"}
    }
} -%}

{%- set stage_tables_ldts = {
    "stg_dich_vu": "LOAD_DATETIME"
} -%}

{{ automate_dv.pit(source_model=source_model, src_pk=src_pk,
                   as_of_dates_table=as_of_dates_table,
                   satellites=satellites,
                   stage_tables_ldts=stage_tables_ldts,
                   src_ldts=src_ldts,
                   src_extra_columns=none) }}
