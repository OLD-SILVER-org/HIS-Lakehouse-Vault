/*

Doanh thu theo Khoa Phòng & Tỷ trọng BHYT

Mục tiêu
Giúp Ban Giám đốc và Giám đốc Tài chính theo dõi hiệu suất đóng góp tài chính
    của từng Khoa/Phòng


*/

SELECT dkp.ten_don_vi ,
    f1.NGAY,
	f1.tong_doanh_thu_thuc ,
    f1.tong_tien_bh ,
    f1.tong_tien_nb_tu_tra ,
    f1.tong_tien_nb_cung_chi_tra
FROM data_mart.fact_doanh_thu_theo_khoa f1
INNER JOIN data_mart.dim_khoa_phong dkp ON f1.KHOA_PK = dkp.DON_VI_PK
ORDER BY tong_doanh_thu_thuc
