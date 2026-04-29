/* 
   ==========================================================================
   DATASET: Xu hướng sử dụng dịch vụ theo thời gian (Service Usage Trends)
   ==========================================================================
   MỤC ĐÍCH: Theo dõi tần suất sử dụng của các dịch vụ y tế theo ngày/tháng/năm.
             Giúp dự báo nhu cầu vật tư, nhân lực và máy móc.
   
   ĐỐI TƯỢNG: Trưởng khoa CLS, Phòng Kế hoạch, Ban Giám đốc.
   
   GỢI Ý CHART: 
   - Time-series Area Chart: Tổng số lần sử dụng theo thời gian (ngay).
   - Table with Sparklines: Top 10 dịch vụ có mức tăng trưởng mạnh nhất.
   ==========================================================================
*/
SELECT 
    f.NGAY,
    d.TEN_DICH_VU,
    -- TONG_SO_LUONG: Tổng số lượng dịch vụ đã thực hiện (bao gồm số lượng > 1 trên mỗi chỉ định)
    f.TONG_SO_LUONG as so_lan_su_dung,
    -- SO_BEN_NHAN: Số lượng bệnh nhân duy nhất sử dụng dịch vụ này trong ngày
    f.SO_BEN_NHAN as so_luot_benh_nhan
FROM public_data_mart.fact_doanh_thu_theo_dich_vu f
LEFT JOIN public_data_mart.dim_dich_vu d ON f.DICH_VU_PK = d.DICH_VU_PK
ORDER BY f.NGAY DESC, f.TONG_SO_LUONG DESC