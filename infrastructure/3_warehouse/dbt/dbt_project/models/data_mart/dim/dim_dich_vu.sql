{{ config(
    materialized='table',
    schema='data_mart'
) }}

WITH latest_sat AS (
    SELECT 
        DICH_VU_PK,
        ten,
        loai_dich_vu,
        gia_bao_hiem,
        gia_khong_bao_hiem,
        don_vi_tinh_id,
        khong_su_dung,
        active,
        LOAD_DATETIME,
        ROW_NUMBER() OVER (
            PARTITION BY DICH_VU_PK 
            ORDER BY LOAD_DATETIME DESC
        ) as row_num
    FROM {{ ref('sat_dich_vu') }}
),

final AS (
    SELECT
        h.DICH_VU_PK,
        h.code_dichvu AS MA_DICH_VU,
        s.ten AS TEN_DICH_VU,
        s.loai_dich_vu AS LOAI_DICH_VU,
        s.gia_bao_hiem AS GIA_BAO_HIEM,
        s.gia_khong_bao_hiem AS GIA_DICH_VU,
        s.don_vi_tinh_id AS DON_VI_TINH_ID,
        s.active AS IS_ACTIVE,
        h.LOAD_DATETIME AS CREATED_AT,
        s.LOAD_DATETIME AS UPDATED_AT
    FROM {{ ref('hub_dich_vu') }} h
    LEFT JOIN latest_sat s 
        ON h.DICH_VU_PK = s.DICH_VU_PK 
        AND s.row_num = 1
    WHERE s.khong_su_dung = false OR s.khong_su_dung IS NULL
)

SELECT * FROM final
