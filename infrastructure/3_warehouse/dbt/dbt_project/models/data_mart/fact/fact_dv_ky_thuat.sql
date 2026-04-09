{{ config(
    materialized='table',
    schema='data_mart'
) }}

{#
    FACT_DV_KY_THUAT - Bảng Fact sự kiện Thực hiện Kỹ thuật / Cận Lâm Sàng
    Grain: Mỗi dòng = 1 kỹ thuật (XN/XQ/THDV...) được thực hiện trong 1 đợt điều trị
    Nguồn: link_dv_ky_thuat + sat_dv_ky_thuat
    FK Dims: DV_KY_THUAT_PK, DOT_DIEU_TRI_PK, BENH_NHAN_PK (qua link_benh_nhan_dieu_tri)
#}

WITH latest_sat AS (
    SELECT
        DV_KY_THUAT_PK,   -- sat_dv_ky_thuat là Hub Sat, PK là DV_KY_THUAT_PK
        trang_thai,
        cap_cuu,
        theo_yeu_cau,
        uu_tien,
        khong_thuc_hien,
        ly_do_khong_thuc_hien,
        tam_ung,
        thanh_toan_sau,
        so_lan_goi,
        thoi_gian_lay_so,
        thoi_gian_tiep_nhan,
        thoi_gian_bat_dau,
        thoi_gian_hoan_thanh,
        thoi_gian_xac_nhan_khong_thuc_hien,
        trang_thai_thong_bao,
        ROW_NUMBER() OVER (PARTITION BY DV_KY_THUAT_PK ORDER BY LOAD_DATETIME DESC) AS row_num
    FROM {{ ref('sat_dv_ky_thuat') }}
),

-- Lấy BENH_NHAN_PK thông qua DOT_DIEU_TRI_PK
link_bn AS (
    SELECT
        DOT_DIEU_TRI_PK,
        BENH_NHAN_PK
    FROM {{ ref('link_benh_nhan_dieu_tri') }}
),

final AS (
    SELECT
        lk.LINK_DV_KY_THUAT_PK,

        -- === Dimension Keys (FK) ===
        lk.DV_KY_THUAT_PK,
        lk.DOT_DIEU_TRI_PK,
        bn.BENH_NHAN_PK,

        -- === Human Readable Names (Added per User Request) ===
        dbn.MA_NB,
        dbn.TEN_BENH_NHAN,
        ddt.MA_HO_SO,

        -- === Trạng thái thực hiện ===
        s.trang_thai                            AS TRANG_THAI,
        s.khong_thuc_hien                       AS KHONG_THUC_HIEN,
        s.ly_do_khong_thuc_hien                 AS LY_DO_KHONG_THUC_HIEN,
        s.trang_thai_thong_bao                  AS TRANG_THAI_THONG_BAO,

        -- === Phân loại ưu tiên ===
        s.cap_cuu                               AS CAP_CUU,
        s.theo_yeu_cau                          AS THEO_YEU_CAU,
        s.uu_tien                               AS UU_TIEN,

        -- === Tài chính ===
        s.tam_ung                               AS TAM_UNG,
        s.thanh_toan_sau                        AS THANH_TOAN_SAU,
        s.so_lan_goi                            AS SO_LAN_GOI,

        -- === Timestamps ===
        s.thoi_gian_lay_so                      AS THOI_GIAN_LAY_SO,
        s.thoi_gian_tiep_nhan                   AS THOI_GIAN_TIEP_NHAN,
        s.thoi_gian_bat_dau                     AS THOI_GIAN_BAT_DAU,
        s.thoi_gian_hoan_thanh                  AS THOI_GIAN_HOAN_THANH,
        s.thoi_gian_xac_nhan_khong_thuc_hien    AS THOI_GIAN_XAC_NHAN_KHONG_THUC_HIEN,

        -- === Metadata ===
        lk.LOAD_DATETIME                        AS CREATED_AT

    FROM {{ ref('link_dv_ky_thuat') }} lk
    LEFT JOIN latest_sat s
        ON lk.DV_KY_THUAT_PK = s.DV_KY_THUAT_PK AND s.row_num = 1
    LEFT JOIN link_bn bn
        ON lk.DOT_DIEU_TRI_PK = bn.DOT_DIEU_TRI_PK

    -- Joins with Dim for Readable Names
    LEFT JOIN {{ ref('dim_benh_nhan') }} dbn
        ON bn.BENH_NHAN_PK = dbn.BENH_NHAN_PK
    LEFT JOIN {{ ref('dim_dot_dieu_tri') }} ddt
        ON lk.DOT_DIEU_TRI_PK = ddt.DOT_DIEU_TRI_PK
)

SELECT * FROM final
