mục tiêu ; xây dựng data fake cho dữ liệu streaming để lấy số đưa vào cv .
các bảng sinh data : chủ yếu sẽ là cấc bảng ct
bảng quan trọng nhất  là ct_dot_deu_tri


tham số : 
records_per_minute : (records_per_minute) số bảng ghi sinh ra mỗi phút cho fake
tiền tố: fake_ cho các row fake

các giá trị mặc định để tránh null fk:
dm_bo_chi_dinh : id :458
dm_benh_nhan :
ids = [
    73973, 73974, 73975, 73976, 73977, 73978, 73979, 73980, 73981, 73982,
    73983, 73984, 73985, 73986, 73987, 73988, 73989, 73990, 73991, 73992,
    73993, 73994, 73995, 73996, 73997, 73998, 73999, 74000, 74001, 74002,
    74003, 74004, 74005, 74006, 74007, 74008, 74009, 74010, 74011, 74012,
    74013, 74014, 74015, 74016, 74017, 74018, 74019, 74020, 74021, 74022,
    74023, 74024, 74025, 74026, 74027, 74029, 75742, 74030, 74031, 74032,
    74033, 74034, 74035, 74036, 74037, 74038, 74039, 74040, 74041, 74042,
    74043, 74044, 74045, 74046, 74047, 74048, 74049, 74050, 74051, 74052,
    74053, 74054, 74055, 74056, 74057, 74058, 74059, 74060, 74061, 74062,
    74063, 74064, 74065, 74066, 74067, 74068, 74069, 74070, 74071, 74072
]
dm_chuyen_khoa : id trong chuỗi 
:5078, 1660, 3284, 1677, 3828, 3829, 3831, 3832, 3837, 1667,
1703, 2542, 657, 556, 1726, 1733, 1739, 1752, 2502, 3987,
5064, 5808, 6413, 6554, 6702, 6755, 6760, 6762, 2503, 2548,
2592, 3059, 3528, 2865, 3169, 3081, 741, 3686, 742, 2586,
1020, 1005, 4826, 1007, 5803, 1006, 1032, 1489, 1490, 3200,
3202, 3203, 1491, 1494, 1497, 1500, 149, 2879, 73, 74,
6412, 1131, 1634, 6204, 1604, 1605, 1606, 1612, 1613, 1614,
1615, 1621, 3838, 3841, 3842, 3844, 3846, 3848, 3849, 3862,
3869, 3877, 3878, 3879, 3880, 3882, 3888, 1201, 3893, 3902,
3903, 3909, 1637, 1610, 1652, 1662, 1669, 1684, 1699, 1701

dm_doi_tuong_kcb: 
id :10

dm_khoa: lấy id 10 (test)
dm_nguon_nb: id 52
dm_nhom_dich_vu_cap_1 :id 3

DDL:
-- pgsql_source.ct_dot_dieu_tri definition

-- Drop table

-- DROP TABLE pgsql_source.ct_dot_dieu_tri;

CREATE TABLE pgsql_source.ct_dot_dieu_tri (
	id int4 NULL,
	cap_cuu bool NULL,
	chi_nam_sinh bool NULL,
	dan_toc_id float4 NULL,
	doi_tuong int4 NULL,
	doi_tuong_kcb int4 NULL,
	email varchar(1024) NULL,
	gioi_tinh int4 NULL,
	kham_suc_khoe bool NULL,
	khoa_id int4 NULL,
	khoa_tiep_don_id int4 NULL,
	loai_benh_an_id varchar(1024) NULL,
	loai_doi_tuong_id float4 NULL,
	ma_benh_an varchar(1024) NULL,
	ma_ho_so int8 NULL,
	ma_nb int8 NULL,
	mac_dinh bool NULL,
	nb_thong_tin_id int4 NULL,
	ngay_sinh varchar(1024) NULL,
	nghe_nghiep_id varchar(1024) NULL,
	ngoai_vien bool NULL,
	nguoi_lap_benh_an_id varchar(1024) NULL,
	nhom_mau varchar(1024) NULL,
	noi_lam_viec varchar(1024) NULL,
	phan_loai_nb_id varchar(1024) NULL,
	quoc_tich_id int4 NULL,
	so_bao_hiem_xa_hoi varchar(1024) NULL,
	so_dien_thoai varchar(1024) NULL,
	so_ngay_dieu_tri int8 NULL,
	so_phoi varchar(1024) NULL,
	ten_nb varchar(1024) NULL,
	ten_nb_khong_dau varchar(1024) NULL,
	thoi_gian_lap_benh_an varchar(1024) NULL,
	thoi_gian_ra_vien varchar(1024) NULL,
	thoi_gian_vao_vien varchar(1024) NULL,
	tiem_chung bool NULL,
	trang_thai int4 NULL,
	uu_tien bool NULL,
	duyet_chi_phi varchar(1024) NULL,
	bang_lai_xe_id varchar(1024) NULL,
	ma_doi_tuong_kcb_id varchar(1024) NULL,
	nhan_vien_kinh_doanh_id varchar(1024) NULL,
	can_nang_vao_vien varchar(1024) NULL,
	cong_ty_bao_hiem_id varchar(1024) NULL,
	phan_loai_doi_tuong float4 NULL,
	nguoi_duyet_chi_phi_id varchar(1024) NULL,
	nguoi_gui_duyet_chi_phi_id varchar(1024) NULL,
	nguoi_tu_choi_duyet_chi_phi_id varchar(1024) NULL,
	loai_lien_ket varchar(1024) NULL,
	nb_lien_ket_id varchar(1024) NULL,
	ho_ngheo bool NULL,
	active bool NULL,
	deleted int4 NULL,
	created_at timestamptz NULL,
	updated_at timestamptz NULL
);

data sample :
47451	false	false		1	1		2	false	1	1				9071977705	9071977705	false	5808	1969-08-16 00:00:00		false					2		+61 420059021	1		Hudson Ray Watson	Hudson Ray Watson			2024-03-12 15:17:16	false	5	false							20.0						false	true	0	2025-03-09 14:46:40.964 +0700	2025-03-09 14:46:49.474 +0700
47609	false	false		1	1		2	false	1	1				9071857791	9071857791	true	35378	1995-09-12 00:00:00		false					2		+61 403712828	1		Valentina Barrett Pollard	Valentina Barrett Pollard			2024-03-10 09:06:08	false	5	false							10.0						false	true	0	2025-03-09 14:46:49.538 +0700	2025-03-09 14:46:49.538 +0700
47610	false	false		1	1		2	false	1	1				9071857790	9071857790	true	35379	1935-10-28 00:00:00		false					2			1		Gunnar Nova Shepherd	Gunnar Nova Shepherd			2024-03-10 09:04:14	false	5	false							10.0						false	true	0	2025-03-09 14:46:49.564 +0700	2025-03-09 14:46:49.564 +0700
47611	false	false		1	1		1	false	1	1				9071857799	9071857799	true	35380	1992-01-01 00:00:00		false					2		+61 476630410	1		George Thalia Hannay	George Thalia Hannay			2024-03-10 09:01:56	false	5	false							10.0						false	true	0	2025-03-09 14:46:49.594 +0700	2025-03-09 14:46:49.594 +0700


-----------------
ct_phieu_thu
DDL:
-- pgsql_source.ct_phieu_thu definition

-- Drop table

-- DROP TABLE pgsql_source.ct_phieu_thu;

CREATE TABLE pgsql_source.ct_phieu_thu (
	id int4 NULL,
	active bool NULL,
	deleted int4 NULL,
	nb_dot_dieu_tri_id int4 NULL,
	ca_lam_viec_id float4 NULL,
	doi_tuong_kcb int4 NULL,
	ds_ma_giam_gia_id varchar(1024) NULL,
	ghi_chu text NULL,
	hinh_thuc_mien_giam float4 NULL,
	hoa_don_id varchar(1024) NULL,
	ky_hieu varchar(1024) NULL,
	loai_phieu_thu int4 NULL,
	nb_goi_dv_id varchar(1024) NULL,
	nha_thu_ngan_id float4 NULL,
	nho_hon_muc_cung_chi_tra bool NULL,
	phan_tram_mien_giam float4 NULL,
	quay_id float4 NULL,
	so_phieu int4 NULL,
	thanh_tien float4 NULL,
	thanh_toan int4 NULL,
	thoi_gian_huy_thanh_toan varchar(1024) NULL,
	thoi_gian_thanh_toan varchar(1024) NULL,
	thu_ngan_huy_thanh_toan_id float4 NULL,
	thu_ngan_id float4 NULL,
	tien_bh_thanh_toan float4 NULL,
	tien_bh_thanh_toan_trong_goi float4 NULL,
	tien_giam_gia float4 NULL,
	tien_hoan_tra float4 NULL,
	tien_mien_giam_dich_vu float4 NULL,
	tien_mien_giam_phieu_thu float4 NULL,
	tien_mien_giam_phieu_thu_nhap_vao float4 NULL,
	tien_nb_cung_chi_tra float4 NULL,
	tien_nb_cung_chi_tra_trong_goi float4 NULL,
	tien_nb_phu_thu float4 NULL,
	tien_nb_tu_tra float4 NULL,
	tien_nguon_khac float4 NULL,
	tien_tai_tro_bao_hiem float4 NULL,
	tien_tai_tro_khong_bao_hiem float4 NULL,
	trang_thai_hoa_don int4 NULL,
	hoan_ung bool NULL,
	loai_mien_giam varchar(1024) NULL,
	phieu_doi_tra_id varchar(1024) NULL,
	thoi_gian_tao_phieu varchar(1024) NULL,
	thoi_gian_cap_nhat_phieu varchar(1024) NULL,
	created_at timestamptz NULL,
	updated_at timestamptz NULL
);
sample data :
596	true	0	101637	1.0	1			20.0		Westmead / 24	0		1.0	false	0.0	2.0	91717746	3619100.0	50		2025-04-27 09:46:59		429.0	0.0	0.0	0.0	0.0	233900.0	0.0	0.0	0.0	0.0	0.0	3853000.0	0.0	0.0	0.0	10	false			2025-04-27 07:31:32.868523	2025-04-27 09:46:59.322542	2025-04-27 07:31:32.868 +0700	2025-04-27 09:46:59.322 +0700
685	true	0	101794	1.0	1					Westmead / 24	0		1.0	false	0.0	1.0	91717847	588000.0	50		2025-04-28 15:26:46		429.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	0.0	588000.0	0.0	0.0	0.0	10	false			2025-04-28 10:40:10.010895	2025-04-28 15:26:46.245994	2025-04-28 10:40:10.010 +0700	2025-04-28 15:26:46.245 +0700
621	true	0	101661	1.0	1			10.0		Westmead / 24	0		1.0	false	10.0	2.0	91717767	2105100.0	50		2025-04-27 11:11:29		217.0	0.0	0.0	0.0	0.0	0.0	233900.0	0.0	0.0	0.0	0.0	2339000.0	0.0	0.0	0.0	10	false			2025-04-27 10:36:44.196713	2025-04-27 11:11:29.960168	2025-04-27 10:36:44.196 +0700	2025-04-27 11:11:29.960 +0700