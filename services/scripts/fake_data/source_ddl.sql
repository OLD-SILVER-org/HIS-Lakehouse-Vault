-- DROP SCHEMA pgsql_source;
CREATE SCHEMA pgsql_source AUTHORIZATION postgres;
-- DROP SEQUENCE pgsql_source.hospital_configs_id_seq;
CREATE SEQUENCE pgsql_source.hospital_configs_id_seq INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE;
-- pgsql_source.ct_address definition
-- Drop table
-- DROP TABLE ct_address;
CREATE TABLE ct_address (
    nb_dot_dieu_tri_id int4 NULL,
    so_nha varchar(1024) NULL,
    so_nha_tam_tru varchar(1024) NULL,
    xa_phuong_id float4 NULL,
    xa_phuong_tam_tru_id varchar(1024) NULL,
    quan_huyen_id float4 NULL,
    quan_huyen_tam_tru_id varchar(1024) NULL,
    tinh_thanh_pho_id float4 NULL,
    tinh_thanh_pho_tam_tru_id varchar(1024) NULL,
    dia_chi_cong_ty varchar(1024) NULL,
    ten_cong_ty varchar(1024) NULL,
    created_at timestamptz NULL,
    updated_at timestamptz NULL
);
-- pgsql_source.ct_bo_chi_dinh definition
-- Drop table
-- DROP TABLE ct_bo_chi_dinh;
CREATE TABLE ct_bo_chi_dinh (
    id int4 NULL,
    nb_dot_dieu_tri_id int4 NULL,
    bo_chi_dinh_id int4 NULL,
    thoi_gian_chi_dinh varchar(1024) NULL,
    active bool NULL,
    deleted int4 NULL,
    created_at timestamptz NULL,
    updated_at timestamptz NULL
);
-- pgsql_source.ct_dich_vu definition
-- Drop table
-- DROP TABLE ct_dich_vu;
CREATE TABLE ct_dich_vu (
    id int4 NULL,
    nb_dot_dieu_tri_id int4 NULL,
    bac_si_chi_dinh_id int4 NULL,
    chi_dinh_tu_dich_vu_id int4 NULL,
    chi_dinh_tu_loai_dich_vu int4 NULL,
    dich_vu_id int4 NULL,
    doi_tuong_kcb int4 NULL,
    dung_tuyen int4 NULL,
    ghi_chu text NULL,
    gia_bao_hiem float4 NULL,
    gia_goc varchar(1024) NULL,
    gia_khong_bao_hiem float4 NULL,
    gia_phu_thu float4 NULL,
    khoa_chi_dinh_id int4 NULL,
    khong_thu_tien bool NULL,
    khong_tinh_tien bool NULL,
    loai_dich_vu int4 NULL,
    loai_doi_tuong_id float4 NULL,
    loai_hinh_thanh_toan_id varchar(1024) NULL,
    mien_cung_chi_tra bool NULL,
    muc_huong varchar(1024) NULL,
    nb_bo_chi_dinh_id float4 NULL,
    nb_chuyen_khoa_id varchar(1024) NULL,
    nb_goi_dv_chi_tiet_id varchar(1024) NULL,
    nb_goi_pt_tt_id varchar(1024) NULL,
    nb_the_bao_hiem_id varchar(1024) NULL,
    ngoai_vien bool NULL,
    phan_tram_mien_giam_dich_vu_bh float4 NULL,
    phan_tram_mien_giam_dich_vu_khong_bh float4 NULL,
    phat_hanh_hoa_don bool NULL,
    phieu_doi_tra_id varchar(1024) NULL,
    phieu_thu_id float4 NULL,
    so_luong float4 NULL,
    stt_hien_thi varchar(1024) NULL,
    thanh_toan int4 NULL,
    thoi_gian_chi_dinh varchar(1024) NULL,
    thoi_gian_thuc_hien varchar(1024) NULL,
    tien_bh_thanh_toan float4 NULL,
    tien_giam_gia_bh float4 NULL,
    tien_giam_gia_khong_bh float4 NULL,
    tien_mien_giam_dich_vu_bh float4 NULL,
    tien_mien_giam_dich_vu_khong_bh float4 NULL,
    tien_mien_giam_dich_vu_nhap_vao float4 NULL,
    tien_mien_giam_phieu_thu_bh float4 NULL,
    tien_mien_giam_phieu_thu_khong_bh float4 NULL,
    tien_nb_cung_chi_tra float4 NULL,
    tien_nb_phu_thu float4 NULL,
    tien_nb_trai_tuyen float4 NULL,
    tien_nb_tu_tra float4 NULL,
    tien_nguon_khac float4 NULL,
    trang_thai_hoan int4 NULL,
    tu_tra bool NULL,
    ty_le_bh_tt int4 NULL,
    ty_le_tt_dv int4 NULL,
    dv_gia_id varchar(1024) NULL,
    nb_phac_do_dieu_tri_id varchar(1024) NULL,
    phac_do_dieu_tri_dich_vu_id varchar(1024) NULL,
    ngoai_vien_id varchar(1024) NULL,
    nguon_khac_id varchar(1024) NULL,
    active bool NULL,
    deleted int4 NULL,
    created_at timestamptz NULL,
    updated_at timestamptz NULL
);
-- pgsql_source.ct_dot_dieu_tri definition
-- Drop table
-- DROP TABLE ct_dot_dieu_tri;
CREATE TABLE ct_dot_dieu_tri (
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
-- pgsql_source.ct_dv_kham definition
-- Drop table
-- DROP TABLE ct_dv_kham;
CREATE TABLE ct_dv_kham (
    id int4 NULL,
    nb_dot_dieu_tri_id int4 NULL,
    bac_si_ket_luan_id float4 NULL,
    bac_si_kham_id float4 NULL,
    dot_kham_moi bool NULL,
    nguoi_phien_dich_id varchar(1024) NULL,
    stt_chuyen_khoa varchar(1024) NULL,
    thiet_lap varchar(1024) NULL,
    thoi_gian_kham varchar(1024) NULL,
    thoi_gian_ket_luan varchar(1024) NULL,
    active bool NULL,
    deleted int4 NULL,
    created_at timestamptz NULL,
    updated_at timestamptz NULL
);
-- pgsql_source.ct_dv_kham_ket_luan definition
-- Drop table
-- DROP TABLE ct_dv_kham_ket_luan;
CREATE TABLE ct_dv_kham_ket_luan (
    id int4 NULL,
    nb_dot_dieu_tri_id int4 NULL,
    huong_dieu_tri float4 NULL,
    ket_qua_dieu_tri float4 NULL,
    loi_dan text NULL,
    phong_hen_kham_id float4 NULL,
    so_ngay_cho_don float4 NULL,
    thoi_gian_hen_tai_kham varchar(1024) NULL,
    thoi_gian_ket_luan varchar(1024) NULL,
    so_hen_kham varchar(1024) NULL,
    thong_tin_theo_doi varchar(1024) NULL,
    den_ngay varchar(1024) NULL,
    tu_ngay varchar(1024) NULL,
    created_at timestamptz NULL,
    updated_at timestamptz NULL
);
-- pgsql_source.ct_dv_ky_thuat definition
-- Drop table
-- DROP TABLE ct_dv_ky_thuat;
CREATE TABLE ct_dv_ky_thuat (
    id int4 NULL,
    nb_dot_dieu_tri_id int4 NULL,
    cap_cuu bool NULL,
    hinh_thuc_tt_ksk float4 NULL,
    in_phieu_chi_dinh int4 NULL,
    ngoai_vien_id varchar(1024) NULL,
    phieu_in_id float4 NULL,
    phong_thuc_hien_id float4 NULL,
    so_lan_goi float4 NULL,
    so_phieu_id float4 NULL,
    stt float4 NULL,
    tam_ung bool NULL,
    thanh_toan_sau bool NULL,
    theo_yeu_cau bool NULL,
    thoi_gian_lay_so varchar(1024) NULL,
    thoi_gian_tiep_nhan varchar(1024) NULL,
    thuc_hien_tai_khoa bool NULL,
    trang_thai int4 NULL,
    tu_van_vien_id varchar(1024) NULL,
    uu_tien bool NULL,
    ly_do_khong_thuc_hien varchar(1024) NULL,
    thoi_gian_xac_nhan_khong_thuc_hien varchar(1024) NULL,
    khong_thuc_hien bool NULL,
    ly_doi_khong_thuc_hien varchar(1024) NULL,
    trang_thai_thong_bao varchar(1024) NULL,
    thoi_gian_bat_dau varchar(1024) NULL,
    thoi_gian_hoan_thanh varchar(1024) NULL,
    active bool NULL,
    deleted int4 NULL,
    created_at timestamptz NULL,
    updated_at timestamptz NULL
);
-- pgsql_source.ct_kham_suc_khoe definition
-- Drop table
-- DROP TABLE ct_kham_suc_khoe;
CREATE TABLE ct_kham_suc_khoe (
    id int4 NULL,
    chuc_vu varchar(1024) NULL,
    den_thoi_gian_kham varchar(1024) NULL,
    den_thoi_gian_lay_mau varchar(1024) NULL,
    dia_diem_kham varchar(1024) NULL,
    dia_diem_lay_mau varchar(1024) NULL,
    ds_bo_chi_dinh_id varchar(1024) NULL,
    ds_dich_vu_id varchar(1024) NULL,
    hinh_thuc_tt_dv_ngoai_hd float4 NULL,
    hop_dong_ksk_id int4 NULL,
    ma_nhan_vien varchar(1024) NULL,
    ngoai_vien bool NULL,
    phong_ban varchar(1024) NULL,
    stt int4 NULL,
    thoi_gian_hoan_thanh varchar(1024) NULL,
    trang_thai int4 NULL,
    tu_thoi_gian_kham varchar(1024) NULL,
    tu_thoi_gian_lay_mau varchar(1024) NULL,
    hinh_thuc_tt_dv_trong_hd float4 NULL,
    created_at timestamptz NULL,
    updated_at timestamptz NULL
);
-- pgsql_source.ct_nguon_nb definition
-- Drop table
-- DROP TABLE ct_nguon_nb;
CREATE TABLE ct_nguon_nb (
    nb_dot_dieu_tri_id int4 NULL,
    ghi_chu varchar(1024) NULL,
    nguoi_gioi_thieu_id float4 NULL,
    nguon_nb_id float4 NULL,
    created_at timestamptz NULL,
    updated_at timestamptz NULL
);
-- pgsql_source.ct_phieu_thu definition
-- Drop table
-- DROP TABLE ct_phieu_thu;
CREATE TABLE ct_phieu_thu (
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
-- pgsql_source.dm_benh_nhan definition
-- Drop table
-- DROP TABLE dm_benh_nhan;
CREATE TABLE dm_benh_nhan (
    nb_thong_tin_id int4 NULL,
    ma_nb int8 NULL,
    email varchar(1024) NULL,
    ngay_sinh varchar(1024) NULL,
    noi_lam_viec varchar(1024) NULL,
    so_dien_thoai varchar(1024) NULL,
    ten_nb varchar(1024) NULL,
    ten_nb_khong_dau varchar(1024) NULL,
    created_at timestamptz NULL,
    updated_at timestamptz NULL
);
-- pgsql_source.dm_bo_chi_dinh definition
-- Drop table
-- DROP TABLE dm_bo_chi_dinh;
CREATE TABLE dm_bo_chi_dinh (
    id int4 NULL,
    code_bo_chi_dinh varchar(1024) NULL,
    ten varchar(1024) NULL,
    ds_bac_si_chi_dinh_id varchar(1024) NULL,
    ds_doi_tuong_su_dung varchar(1024) NULL,
    ds_kho_id varchar(1024) NULL,
    ds_loai_dich_vu varchar(1024) NULL,
    han_che_khoa_chi_dinh bool NULL,
    hop_dong_ksk_id float4 NULL,
    thuoc_chi_dinh_ngoai bool NULL,
    ket_qua_lau bool NULL,
    active bool NULL,
    deleted int4 NULL,
    created_at timestamptz NULL,
    updated_at timestamptz NULL
);
-- pgsql_source.dm_chuyen_khoa definition
-- Drop table
-- DROP TABLE dm_chuyen_khoa;
CREATE TABLE dm_chuyen_khoa (
    id int4 NULL,
    ten varchar(1024) NULL,
    code_chuyen_khoa varchar(1024) NULL,
    active bool NULL,
    deleted int4 NULL,
    created_at timestamptz NULL,
    updated_at timestamptz NULL
);
-- pgsql_source.dm_dich_vu definition
-- Drop table
-- DROP TABLE dm_dich_vu;
CREATE TABLE dm_dich_vu (
    id int4 NULL,
    code_dichvu varchar(1024) NULL,
    ten varchar(1024) NULL,
    don_vi_tinh_id float4 NULL,
    ds_nguon_khac_chi_tra varchar(1024) NULL,
    gia_bao_hiem varchar(1024) NULL,
    gia_khong_bao_hiem float4 NULL,
    khong_tinh_tien float4 NULL,
    loai_dich_vu int4 NULL,
    nhom_dich_vu_cap1_id int4 NULL,
    nhom_dich_vu_cap2_id float4 NULL,
    nhom_dich_vu_cap3_id float4 NULL,
    ten_tuong_duong varchar(1024) NULL,
    thu_ngoai bool NULL,
    ty_le_bh_tt int4 NULL,
    ty_le_tt_dv int4 NULL,
    viet_tat text NULL,
    chi_dinh_sl_le bool NULL,
    nguon_khac_id varchar(1024) NULL,
    gui_vitimes bool NULL,
    mien_phi_giam_doc_duyet bool NULL,
    khong_su_dung bool NULL,
    online_ bool NULL,
    sua_gia bool NULL,
    active bool NULL,
    deleted int4 NULL,
    created_at timestamptz NULL,
    updated_at timestamptz NULL
);
-- pgsql_source.dm_doi_tuong_kcb definition
-- Drop table
-- DROP TABLE dm_doi_tuong_kcb;
CREATE TABLE dm_doi_tuong_kcb (
    id int4 NULL,
    ten varchar NULL,
    created_at timestamp NULL,
    updated_at timestamp NULL
);
-- pgsql_source.dm_dv_discount definition
-- Drop table
-- DROP TABLE dm_dv_discount;
CREATE TABLE dm_dv_discount (
    id int4 NULL,
    discount_percent float4 NULL,
    loai_dich_vu_id varchar(1024) NULL,
    type_discount int4 NULL,
    fix_amount int8 NULL,
    created_at timestamp NULL,
    updated_at timestamp NULL
);
-- pgsql_source.dm_hoc_ham_hoc_vi definition
-- Drop table
-- DROP TABLE dm_hoc_ham_hoc_vi;
CREATE TABLE dm_hoc_ham_hoc_vi (
    id int4 NULL,
    code_hoc_ham varchar(1024) NULL,
    ten varchar(1024) NULL,
    active bool NULL,
    deleted int4 NULL,
    created_at timestamptz NULL,
    updated_at timestamptz NULL
);
-- pgsql_source.dm_hop_dong_ksk definition
-- Drop table
-- DROP TABLE dm_hop_dong_ksk;
CREATE TABLE dm_hop_dong_ksk (
    id int4 NULL,
    code_hop_dong int4 NULL,
    ten varchar(1024) NULL,
    ds_ma_giam_gia_id varchar(1024) NULL,
    hinh_thuc_mien_giam float4 NULL,
    hinh_thuc_tt_dv_ngoai_hd float4 NULL,
    ngay_hieu_luc varchar(1024) NULL,
    phan_tram_mien_giam float4 NULL,
    so_hop_dong varchar(1024) NULL,
    thoi_gian_thanh_ly varchar(1024) NULL,
    tien_chua_thanh_toan float4 NULL,
    tien_da_thanh_toan float4 NULL,
    tien_du_kien float4 NULL,
    tien_du_kien_sau_giam float4 NULL,
    tien_giam_gia float4 NULL,
    tien_mien_giam_dich_vu float4 NULL,
    tien_mien_giam_hop_dong float4 NULL,
    tien_thuc_te float4 NULL,
    tien_thuc_te_sau_giam float4 NULL,
    trang_thai int4 NULL,
    chot_thanh_toan_dv_ksk float4 NULL,
    tien_nb_da_thanh_toan float4 NULL,
    tien_tai_tro_nb float4 NULL,
    nguoi_gioi_thieu_id float4 NULL,
    nguon_nb_id float4 NULL,
    active bool NULL,
    deleted int4 NULL,
    created_at timestamptz NULL,
    updated_at timestamptz NULL
);
-- pgsql_source.dm_khoa definition
-- Drop table
-- DROP TABLE dm_khoa;
CREATE TABLE dm_khoa (
    id int4 NULL,
    code_khoa varchar(1024) NULL,
    ten varchar(1024) NULL,
    ds_tinh_chat_khoa varchar(1024) NULL,
    active bool NULL,
    deleted int4 NULL,
    created_at timestamptz NULL,
    updated_at timestamptz NULL
);
-- pgsql_source.dm_loai_dich_vu definition
-- Drop table
-- DROP TABLE dm_loai_dich_vu;
CREATE TABLE dm_loai_dich_vu (
    id int4 NULL,
    ten varchar NULL,
    created_at timestamp NULL,
    updated_at timestamp NULL
);
-- pgsql_source.dm_nguoi_gioi_thieu definition
-- Drop table
-- DROP TABLE dm_nguoi_gioi_thieu;
CREATE TABLE dm_nguoi_gioi_thieu (
    id int4 NULL,
    code_nguoi_gioi_thieu varchar(1024) NULL,
    ten varchar(1024) NULL,
    ds_nguon_nb_id varchar(1024) NULL,
    active bool NULL,
    deleted int4 NULL,
    created_at timestamptz NULL,
    updated_at timestamptz NULL
);
-- pgsql_source.dm_nguon_nb definition
-- Drop table
-- DROP TABLE dm_nguon_nb;
CREATE TABLE dm_nguon_nb (
    id int4 NULL,
    code_nguon_nb varchar(1024) NULL,
    ten varchar(1024) NULL,
    nguoi_gioi_thieu bool NULL,
    nhom_nguon int4 NULL,
    active bool NULL,
    deleted int4 NULL,
    created_at timestamptz NULL,
    updated_at timestamptz NULL
);
-- pgsql_source.dm_nhan_vien definition
-- Drop table
-- DROP TABLE dm_nhan_vien;
CREATE TABLE dm_nhan_vien (
    id int4 NULL,
    code_nhan_vien varchar(1024) NULL,
    ten varchar(1024) NULL,
    chung_chi varchar(1024) NULL,
    ds_chuyen_khoa_id varchar(1024) NULL,
    email varchar(1024) NULL,
    gioi_tinh varchar(1024) NULL,
    hoc_ham_hoc_vi_id int4 NULL,
    ngay_sinh varchar(1024) NULL,
    van_bang_id int4 NULL,
    active bool NULL,
    deleted int4 NULL,
    created_at timestamptz NULL,
    updated_at timestamptz NULL
);
-- pgsql_source.dm_nhom_dich_vu_cap1 definition
-- Drop table
-- DROP TABLE dm_nhom_dich_vu_cap1;
CREATE TABLE dm_nhom_dich_vu_cap1 (
    id int4 NULL,
    code_service_lvl_1 varchar(1024) NULL,
    ten varchar(1024) NULL,
    loai_dich_vu float4 NULL,
    stt_bang_ke int4 NULL,
    trang_thai_hoan_thanh float4 NULL,
    trang_thai_lay_stt float4 NULL,
    active bool NULL,
    deleted int4 NULL,
    created_at timestamptz NULL,
    updated_at timestamptz NULL
);
-- pgsql_source.dm_nhom_dich_vu_cap2 definition
-- Drop table
-- DROP TABLE dm_nhom_dich_vu_cap2;
CREATE TABLE dm_nhom_dich_vu_cap2 (
    id int4 NULL,
    code_service_lvl_2 varchar(1024) NULL,
    ten varchar(1024) NULL,
    luu_phim_chup bool NULL,
    nhom_dich_vu_cap1_id int4 NULL,
    phieu_chi_dinh_id float4 NULL,
    tach_stt_noi_tru bool NULL,
    tach_stt_uu_tien bool NULL,
    theo_yeu_cau bool NULL,
    tiep_don_cls bool NULL,
    trang_thai_hoan_thanh float4 NULL,
    trang_thai_lay_stt float4 NULL,
    active bool NULL,
    deleted int4 NULL,
    created_at timestamptz NULL,
    updated_at timestamptz NULL
);
-- pgsql_source.dm_nhom_dich_vu_cap3 definition
-- Drop table
-- DROP TABLE dm_nhom_dich_vu_cap3;
CREATE TABLE dm_nhom_dich_vu_cap3 (
    id int4 NULL,
    code_service_lvl_3 varchar(1024) NULL,
    ten varchar(1024) NULL,
    nhom_dich_vu_cap2_id int4 NULL,
    active bool NULL,
    deleted int4 NULL,
    created_at timestamptz NULL,
    updated_at timestamptz NULL
);
-- pgsql_source.dm_phong definition
-- Drop table
-- DROP TABLE dm_phong;
CREATE TABLE dm_phong (
    id int4 NULL,
    code_phong varchar(1024) NULL,
    ten varchar(1024) NULL,
    chuyen_khoa_id float4 NULL,
    dia_diem varchar(1024) NULL,
    ds_loai_phong varchar(1024) NULL,
    khoa_id int4 NULL,
    ngoai_tru bool NULL,
    ngoai_vien bool NULL,
    noi_tru bool NULL,
    online bool NULL,
    active bool NULL,
    deleted int4 NULL,
    created_at timestamptz NULL,
    updated_at timestamptz NULL
);
-- pgsql_source.dm_quan_huyen definition
-- Drop table
-- DROP TABLE dm_quan_huyen;
CREATE TABLE dm_quan_huyen (
    id int4 NULL,
    ten varchar(1024) NULL,
    code_quan_huyen int4 NULL,
    ma_tcqg int4 NULL,
    tinh_thanh_pho_id int4 NULL,
    active bool NULL,
    deleted int4 NULL,
    created_at timestamptz NULL,
    updated_at timestamptz NULL
);
-- pgsql_source.dm_tinh_thanh_pho definition
-- Drop table
-- DROP TABLE dm_tinh_thanh_pho;
CREATE TABLE dm_tinh_thanh_pho (
    id int4 NULL,
    code_province int4 NULL,
    ten varchar(1024) NULL,
    ma_tcqg int4 NULL,
    active bool NULL,
    deleted int4 NULL,
    created_at timestamptz NULL,
    updated_at timestamptz NULL
);
-- pgsql_source.dm_xa_phuong definition
-- Drop table
-- DROP TABLE dm_xa_phuong;
CREATE TABLE dm_xa_phuong (
    xa_phuong_id int4 NULL,
    ten_xa_phuong text NULL,
    quan_huyen_id int4 NULL
);
-- pgsql_source.hospital_configs definition
-- Drop table
-- DROP TABLE hospital_configs;
CREATE TABLE hospital_configs (
    id serial4 NOT NULL,
    table_name varchar(255) NULL,
    column_name varchar(255) NULL,
    value_code varchar(255) NULL,
    description varchar(255) NULL,
    created_at timestamp NULL,
    updated_at timestamp NULL
);