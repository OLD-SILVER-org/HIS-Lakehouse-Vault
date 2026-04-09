{{ config(
    materialized='table',
    schema='data_mart'
) }}

{#
    FACT_KHAM_SUC_KHOE - Bảng Fact sự kiện Khám sức khỏe theo Hợp đồng KSK (Khám đoàn)
    Grain: Mỗi dòng = 1 lần khám sức khỏe của 1 người thuộc 1 hợp đồng KSK
    Nguồn: link_kham_suc_khoe + sat_kham_suc_khoe
    FK Dims: KHAM_SUC_KHOE_PK (Hub), HOP_DONG_KSK_PK → dim_hop_dong_ksk
    Ghi chú: KHAM_SUC_KHOE_PK đây là PK của Hub khám sức khỏe (cá nhân trong đoàn),
             HOP_DONG_KSK_PK là FK liên kết tới hợp đồng KSK của doanh nghiệp.
#}

WITH latest_sat AS (
    SELECT
        KHAM_SUC_KHOE_PK,
        trang_thai,
        chuc_vu,
        phong_ban,
        stt,
        dia_diem_kham,
        dia_diem_lay_mau,
        ngoai_vien,
        hinh_thuc_tt_dv_trong_hd,
        hinh_thuc_tt_dv_ngoai_hd,
        ma_nhan_vien,
        thoi_gian_hoan_thanh,
        tu_thoi_gian_kham,
        den_thoi_gian_kham,
        tu_thoi_gian_lay_mau,
        den_thoi_gian_lay_mau,
        ROW_NUMBER() OVER (PARTITION BY KHAM_SUC_KHOE_PK ORDER BY LOAD_DATETIME DESC) AS row_num
    FROM {{ ref('sat_kham_suc_khoe') }}
),

final AS (
    SELECT
        lk.LINK_KHAM_SUC_KHOE_PK,

        -- === Dimension Keys (FK) ===
        lk.KHAM_SUC_KHOE_PK,
        lk.HOP_DONG_KSK_PK,

        -- === Human Readable Names (Added per User Request) ===
        dhd.TEN_HOP_DONG,
        dhd.SO_HOP_DONG,

        -- === Thông tin đối tượng KSK ===
        s.chuc_vu                       AS CHUC_VU,
        s.phong_ban                     AS PHONG_BAN,
        s.stt                           AS STT,
        s.ma_nhan_vien                  AS MA_NHAN_VIEN_KSK,
        s.ngoai_vien                    AS NGOAI_VIEN,

        -- === Địa điểm ===
        s.dia_diem_kham                 AS DIA_DIEM_KHAM,
        s.dia_diem_lay_mau              AS DIA_DIEM_LAY_MAU,

        -- === Hình thức thanh toán ===
        s.hinh_thuc_tt_dv_trong_hd     AS HINH_THUC_TT_DV_TRONG_HD,
        s.hinh_thuc_tt_dv_ngoai_hd     AS HINH_THUC_TT_DV_NGOAI_HD,

        -- === Trạng thái ===
        s.trang_thai                    AS TRANG_THAI,
        s.thoi_gian_hoan_thanh          AS THOI_GIAN_HOAN_THANH,

        -- === Timestamps khám / lấy mẫu ===
        s.tu_thoi_gian_kham             AS TU_THOI_GIAN_KHAM,
        s.den_thoi_gian_kham            AS DEN_THOI_GIAN_KHAM,
        s.tu_thoi_gian_lay_mau          AS TU_THOI_GIAN_LAY_MAU,
        s.den_thoi_gian_lay_mau         AS DEN_THOI_GIAN_LAY_MAU,

        -- === Metadata ===
        lk.LOAD_DATETIME                AS CREATED_AT

    FROM {{ ref('link_kham_suc_khoe') }} lk
    LEFT JOIN latest_sat s
        ON lk.KHAM_SUC_KHOE_PK = s.KHAM_SUC_KHOE_PK AND s.row_num = 1

    -- Joins with Dim for Readable Names
    LEFT JOIN {{ ref('dim_hop_dong_ksk') }} dhd
        ON lk.HOP_DONG_KSK_PK = dhd.HOP_DONG_KSK_PK
)

SELECT * FROM final
