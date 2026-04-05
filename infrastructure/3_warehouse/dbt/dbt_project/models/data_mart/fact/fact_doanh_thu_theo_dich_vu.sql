{{ config(
    materialized='table',
    schema='data_mart'
) }}

{#
    FACT_DOANH_THU_THEO_DICH_VU - Bảng Aggregate Fact Doanh thu theo Dịch vụ & Ngày
    ─────────────────────────────────────────────────────────────────────────────────
    Grain   : Mỗi dòng = 1 Ngày × 1 Dịch vụ (DICH_VU_PK)
    Nguồn   : fact_chi_dinh_dich_vu (pre-aggregated theo NGAY × DICH_VU_PK)
    FK Dims : DICH_VU_PK (→ dim_dich_vu)

    Cách dùng trong BI:
    ─  Top dịch vụ có doanh thu cao nhất: ORDER BY TONG_DOANH_THU_THUC DESC
    ─  Phân tích theo DOI_TUONG_KCB: BH vs không BH, tỷ lệ BH chi trả
    ─  Xu hướng: SUM theo THANG, QUY, NAM để thấy tăng trưởng từng loại DV

    Measures:
    ─  TONG_DOANH_THU_GOC    = giá niêm yết × số lượng (chưa trừ giảm giá)
    ─  TONG_DOANH_THU_THUC   = tổng tiền thực thu (BH + NB tự trả + NB đồng chi trả)
    ─  TONG_SO_LUONG         = tổng số lượng dịch vụ đã thực hiện
    ─  SO_BENH_NHAN          = số bệnh nhân khác nhau sử dụng dịch vụ
#}

WITH base AS (
    SELECT
        -- === Dimension Keys ===
        DICH_VU_PK,
        DOT_DIEU_TRI_PK,
        BENH_NHAN_PK,
        DOI_TUONG_KCB,

        -- === Phân tách thời gian ===
        DATE_TRUNC('day', THOI_GIAN_CHI_DINH)::DATE        AS NGAY,
        EXTRACT(ISOYEAR FROM THOI_GIAN_CHI_DINH)::INT       AS NAM,
        EXTRACT(QUARTER FROM THOI_GIAN_CHI_DINH)::INT       AS QUY,
        EXTRACT(MONTH   FROM THOI_GIAN_CHI_DINH)::INT       AS THANG,
        EXTRACT(WEEK    FROM THOI_GIAN_CHI_DINH)::INT       AS TUAN,

        -- === Tài chính ===
        NULLIF(GIA_GOC, '')::NUMERIC                                                    AS GIA_GOC_NUM,
        SO_LUONG,
        (NULLIF(GIA_GOC, '')::NUMERIC * SO_LUONG::NUMERIC)                              AS DOANH_THU_GOC,
        COALESCE(NULLIF(TIEN_BH_THANH_TOAN::TEXT,   '')::NUMERIC, 0)                   AS TIEN_BH,
        COALESCE(NULLIF(TIEN_NB_TU_TRA::TEXT,       '')::NUMERIC, 0)                   AS TIEN_NB_TU_TRA,
        COALESCE(NULLIF(TIEN_NB_CUNG_CHI_TRA::TEXT, '')::NUMERIC, 0)                   AS TIEN_NB_CUNG_CHI_TRA

    FROM {{ ref('fact_chi_dinh_dich_vu') }}
    WHERE
        IS_ACTIVE = true
        AND THOI_GIAN_CHI_DINH IS NOT NULL
        AND DICH_VU_PK IS NOT NULL
),

aggregated AS (
    SELECT
        -- === Keys & Time Grain ===
        DICH_VU_PK,
        NGAY,
        NAM,
        QUY,
        THANG,
        TUAN,

        -- === Measures Tài chính ===
        SUM(DOANH_THU_GOC)                                          AS TONG_DOANH_THU_GOC,
        SUM(TIEN_BH)                                                AS TONG_TIEN_BH,
        SUM(TIEN_NB_TU_TRA)                                         AS TONG_TIEN_NB_TU_TRA,
        SUM(TIEN_NB_CUNG_CHI_TRA)                                   AS TONG_TIEN_NB_CUNG_CHI_TRA,
        SUM(TIEN_BH + TIEN_NB_TU_TRA + TIEN_NB_CUNG_CHI_TRA)       AS TONG_DOANH_THU_THUC,

        -- === Measures Khối lượng ===
        SUM(SO_LUONG)                                               AS TONG_SO_LUONG,
        COUNT(*)                                                    AS SO_LUONG_CHI_DINH,
        COUNT(DISTINCT BENH_NHAN_PK)                               AS SO_BEN_NHAN,
        COUNT(DISTINCT DOT_DIEU_TRI_PK)                            AS SO_DOT_DIEU_TRI

    FROM base
    GROUP BY
        DICH_VU_PK,
        NGAY,
        NAM,
        QUY,
        THANG,
        TUAN
)

SELECT * FROM aggregated
