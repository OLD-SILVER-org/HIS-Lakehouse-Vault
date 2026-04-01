{{ config(materialized='pit_incremental') }}

{%- set source_model = 'hub_benh_nhan' -%}
{%- set src_pk = 'BENH_NHAN_PK' -%}
{%- set as_of_dates_table = 'as_of_dates' -%}
{%- set src_ldts = 'LOAD_DATETIME' -%}

{%- set satellites = {
    "sat_benh_nhan": {
        "pk": {"PK": "BENH_NHAN_PK"},
        "ldts": {"LDTS": "LOAD_DATETIME"}
    }
} -%}

{%- set stage_tables_ldts = {
    "stg_benh_nhan": "LOAD_DATETIME"
} -%}

{{ automate_dv.pit(source_model=source_model, src_pk=src_pk,
                   as_of_dates_table=as_of_dates_table,
                   satellites=satellites,
                   stage_tables_ldts=stage_tables_ldts,
                   src_ldts=src_ldts,
                   src_extra_columns=none) }}
