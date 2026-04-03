{{ config(
    materialized='table',
    schema='data_mart'
) }}

WITH latest_sat AS (
    /* Lấy dòng mới nhất cho mỗi bệnh nhân từ Satellite */
    SELECT 
        BENH_NHAN_PK,
        ten_nb,
        ngay_sinh,
        so_dien_thoai,
        email,
        noi_lam_viec,
        ten_nb_khong_dau,
        LOAD_DATETIME,
        ROW_NUMBER() OVER (
            PARTITION BY BENH_NHAN_PK 
            ORDER BY LOAD_DATETIME DESC
        ) as row_num
    FROM {{ ref('sat_benh_nhan') }}
),

final AS (
    SELECT
        h.BENH_NHAN_PK,
        h.ma_nb AS MA_NB,
        s.ten_nb AS TEN_BENH_NHAN,
        s.ngay_sinh AS NGAY_SINH,
        s.so_dien_thoai AS SO_DIEN_THOAI,
        s.email AS EMAIL,
        s.noi_lam_viec AS NOI_LAM_VIEC,
        s.ten_nb_khong_dau AS TEN_KHONG_DAU,
        h.LOAD_DATETIME AS CREATED_AT,
        s.LOAD_DATETIME AS UPDATED_AT
    FROM {{ ref('hub_benh_nhan') }} h
    LEFT JOIN latest_sat s 
        ON h.BENH_NHAN_PK = s.BENH_NHAN_PK 
        AND s.row_num = 1
)

SELECT * FROM final
