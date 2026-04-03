{{ config(
    materialized='table',
    schema='data_mart'
) }}

WITH latest_sat AS (
    SELECT 
        DOT_DIEU_TRI_PK,
        ma_benh_an,
        ma_ho_so,
        ten_nb,
        thoi_gian_vao_vien,
        thoi_gian_ra_vien,
        trang_thai,
        doi_tuong,
        active,
        deleted,
        ROW_NUMBER() OVER (PARTITION BY DOT_DIEU_TRI_PK ORDER BY LOAD_DATETIME DESC) as row_num
    FROM {{ ref('sat_dot_dieu_tri') }}
),

final AS (
    SELECT
        h.DOT_DIEU_TRI_PK,
        h.id AS DOT_DIEU_TRI_ID,
        s.ma_benh_an AS MA_BENH_AN,
        s.ma_ho_so AS MA_HO_SO,
        s.thoi_gian_vao_vien AS THOI_GIAN_VAO_VIEN,
        s.thoi_gian_ra_vien AS THOI_GIAN_RA_VIEN,
        s.trang_thai AS TRANG_THAI_DIEU_TRI,
        s.doi_tuong AS DOI_TUONG_KCB,
        s.active AS IS_ACTIVE,
        h.LOAD_DATETIME AS CREATED_AT
    FROM {{ ref('hub_dot_dieu_tri') }} h
    LEFT JOIN latest_sat s ON h.DOT_DIEU_TRI_PK = s.DOT_DIEU_TRI_PK AND s.row_num = 1
    WHERE s.deleted = 0 OR s.deleted IS NULL
)

SELECT * FROM final
