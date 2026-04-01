{{ config(materialized='view') }}

WITH dates AS (
    SELECT generate_series(
        '2024-01-01'::timestamp,
        '2027-01-01'::timestamp,
        '1 day'::interval
    ) AS AS_OF_DATE
)
SELECT AS_OF_DATE FROM dates
