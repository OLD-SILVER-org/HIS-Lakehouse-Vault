/* 
   ==========================================================================
   DATASET: Chân dung và Hành vi Bệnh nhân (Patient Demographics)
   ==========================================================================
   MỤC ĐÍCH: Hiểu rõ cơ cấu độ tuổi, nhóm tuổi và khu vực làm việc/nơi ở của 
             bệnh nhân để phục vụ công tác Marketing và lên kế hoạch dịch vụ.
   
   ĐỐI TƯỢNG: Phòng Marketing, Phòng Kế hoạch, Ban Giám đốc.
   
   GỢI Ý CHART: 
   - Histogram: Phân bổ độ tuổi bệnh nhân.
   - Pie Chart: Nhóm tuổi bệnh nhân (Trẻ em, Lao động, Người già).
   - Word Cloud: Nơi làm việc của bệnh nhân.
   ==========================================================================
*/
SELECT 
    b.MA_NB,
    b.TEN_BENH_NHAN,
    b.NOI_LAM_VIEC,
    EXTRACT(YEAR FROM AGE(b.NGAY_SINH)) as do_tuoi,
    CASE 
        WHEN EXTRACT(YEAR FROM AGE(b.NGAY_SINH)) < 16 THEN 'Trẻ em'
        WHEN EXTRACT(YEAR FROM AGE(b.NGAY_SINH)) BETWEEN 16 AND 60 THEN 'Lao động'
        ELSE 'Người già'
    END as nhom_tuoi,
    k.THOI_GIAN_KHAM::DATE as ngay_kham,
    k.DOT_DIEU_TRI_PK
FROM data_mart.dim_benh_nhan b
INNER JOIN data_mart.fact_kham_benh k ON b.BENH_NHAN_PK = k.BENH_NHAN_PK
