package core;

/**
 * A container class for TableProcessor implementations related to 'ct_*' (clinical trial) tables
 * for batch processing.
 */
public class CtProcessor {
    public static class CtAddressProcessor implements TableProcessor {
        @Override public String getSourceTableName() { return "ct_address"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  nb_dot_dieu_tri_id INT, so_nha STRING, xa_phuong_id FLOAT, xa_phuong_tam_tru_id FLOAT,
                  quan_huyen_id FLOAT, quan_huyen_tam_tru_id FLOAT, tinh_thanh_pho_id FLOAT,
                  tinh_thanh_pho_tam_tru_id FLOAT, dia_chi_cong_ty STRING, ten_cong_ty STRING,
                  created_at STRING, updated_at STRING""";
        }
    }

    public static class CtBoChiDinhProcessor implements TableProcessor {
        @Override public String getSourceTableName() { return "ct_bo_chi_dinh"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  id INT, nb_dot_dieu_tri_id INT, bo_chi_dinh_id INT, thoi_gian_chi_dinh STRING,
                  active BOOLEAN, deleted INT, created_at STRING, updated_at STRING""";
        }
    }

    public static class CtDichVuProcessor implements TableProcessor {
        @Override public String getSourceTableName() { return "ct_dich_vu"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  id INT, nb_dot_dieu_tri_id INT, bac_si_chi_dinh_id INT, chi_dinh_tu_dich_vu_id INT,
                  chi_dinh_tu_loai_dich_vu INT, dich_vu_id INT, doi_tuong_kcb INT, dung_tuyen INT,
                  ghi_chu STRING, gia_bao_hiem FLOAT, gia_goc STRING, gia_khong_bao_hiem FLOAT,
                  gia_phu_thu FLOAT, khoa_chi_dinh_id INT, khong_thu_tien BOOLEAN, khong_tinh_tien BOOLEAN,
                  loai_dich_vu INT, loai_doi_tuong_id FLOAT, loai_hinh_thanh_toan_id STRING, mien_cung_chi_tra BOOLEAN,
                  muc_huong STRING, nb_bo_chi_dinh_id FLOAT, nb_chuyen_khoa_id STRING, nb_goi_dv_chi_tiet_id STRING,
                  nb_goi_pt_tt_id STRING, nb_the_bao_hiem_id STRING, ngoai_vien BOOLEAN, phan_tram_mien_giam_dich_vu_bh FLOAT,
                  phan_tram_mien_giam_dich_vu_khong_bh FLOAT, phat_hanh_hoa_don BOOLEAN, phieu_doi_tra_id STRING,
                  phieu_thu_id FLOAT, so_luong FLOAT, stt_hien_thi STRING, thanh_toan INT,
                  thoi_gian_chi_dinh STRING, thoi_gian_thuc_hien STRING, tien_bh_thanh_toan FLOAT, tien_giam_gia_bh FLOAT,
                  tien_giam_gia_khong_bh FLOAT, tien_mien_giam_dich_vu_bh FLOAT, tien_mien_giam_dich_vu_khong_bh FLOAT,
                  tien_mien_giam_dich_vu_nhap_vao FLOAT, tien_mien_giam_phieu_thu_bh FLOAT, tien_mien_giam_phieu_thu_khong_bh FLOAT,
                  tien_nb_cung_chi_tra FLOAT, tien_nb_phu_thu FLOAT, tien_nb_trai_tuyen FLOAT, tien_nb_tu_tra FLOAT,
                  tien_nguon_khac FLOAT, trang_thai_hoan INT, tu_tra BOOLEAN, ty_le_bh_tt INT,
                  ty_le_tt_dv INT, dv_gia_id STRING, nb_phac_do_dieu_tri_id STRING, phac_do_dieu_tri_dich_vu_id STRING,
                  ngoai_vien_id STRING, nguon_khac_id STRING, active BOOLEAN, deleted INT,
                  created_at STRING, updated_at STRING""";
        }
    }

    public static class CtDotDieuTriProcessor implements TableProcessor {
        @Override public String getSourceTableName() { return "ct_dot_dieu_tri"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  id INT, cap_cuu BOOLEAN, chi_nam_sinh BOOLEAN, dan_toc_id FLOAT, doi_tuong INT,
                  doi_tuong_kcb INT, email STRING, gioi_tinh INT, kham_suc_khoe BOOLEAN, khoa_id INT,
                  khoa_tiep_don_id INT, loai_benh_an_id STRING, loai_doi_tuong_id FLOAT, ma_benh_an STRING,
                  ma_ho_so BIGINT, ma_nb BIGINT, mac_dinh BOOLEAN, nb_thong_tin_id INT, ngay_sinh STRING,
                  nghe_nghiep_id STRING, ngoai_vien BOOLEAN, nguoi_lap_benh_an_id STRING, nhom_mau STRING,
                  noi_lam_viec STRING, phan_loai_nb_id STRING, quoc_tich_id INT, so_bao_hiem_xa_hoi STRING,
                  so_dien_thoai STRING, so_ngay_dieu_tri BIGINT, so_phoi STRING, ten_nb STRING,
                  ten_nb_khong_dau STRING, thoi_gian_lap_benh_an STRING, thoi_gian_ra_vien STRING,
                  thoi_gian_vao_vien STRING, tiem_chung BOOLEAN, trang_thai INT, uu_tien BOOLEAN,
                  duyet_chi_phi STRING, bang_lai_xe_id STRING, ma_doi_tuong_kcb_id STRING, nhan_vien_kinh_doanh_id STRING,
                  can_nang_vao_vien STRING, cong_ty_bao_hiem_id STRING, phan_loai_doi_tuong FLOAT,
                  nguoi_duyet_chi_phi_id STRING, nguoi_gui_duyet_chi_phi_id STRING, nguoi_tu_choi_duyet_chi_phi_id STRING,
                  loai_lien_ket STRING, nb_lien_ket_id STRING, ho_ngheo BOOLEAN, active BOOLEAN,
                  deleted INT, created_at STRING, updated_at STRING""";
        }
    }

    public static class CtDvKhamProcessor implements TableProcessor {
        @Override public String getSourceTableName() { return "ct_dv_kham"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  id INT, nb_dot_dieu_tri_id INT, bac_si_ket_luan_id FLOAT, bac_si_kham_id FLOAT,
                  dot_kham_moi BOOLEAN, nguoi_phien_dich_id STRING, stt_chuyen_khoa STRING, thiet_lap STRING,
                  thoi_gian_kham STRING, thoi_gian_ket_luan STRING, active BOOLEAN, deleted INT,
                  created_at STRING, updated_at STRING""";
        }
    }

    public static class CtDvKhamKetLuanProcessor implements TableProcessor {
        @Override public String getSourceTableName() { return "ct_dv_kham_ket_luan"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  id INT, nb_dot_dieu_tri_id INT, huong_dieu_tri FLOAT, ket_qua_dieu_tri FLOAT,
                  loi_dan STRING, phong_hen_kham_id FLOAT, so_ngay_cho_don FLOAT, thoi_gian_hen_tai_kham STRING,
                  thoi_gian_ket_luan STRING, so_hen_kham STRING, thong_tin_theo_doi STRING, den_ngay STRING,
                  tu_ngay STRING, created_at STRING, updated_at STRING""";
        }
    }

    public static class CtDvKyThuatProcessor implements TableProcessor {
        @Override public String getSourceTableName() { return "ct_dv_ky_thuat"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  id INT, nb_dot_dieu_tri_id INT, cap_cuu BOOLEAN, hinh_thuc_tt_ksk FLOAT,
                  in_phieu_chi_dinh INT, ngoai_vien_id STRING, phieu_in_id FLOAT, phong_thuc_hien_id FLOAT,
                  so_lan_goi FLOAT, so_phieu_id FLOAT, stt FLOAT, tam_ung BOOLEAN,
                  thanh_toan_sau BOOLEAN, theo_yeu_cau BOOLEAN, thoi_gian_lay_so STRING, thoi_gian_tiep_nhan STRING,
                  thuc_hien_tai_khoa BOOLEAN, trang_thai INT, tu_van_vien_id STRING, uu_tien BOOLEAN,
                  ly_do_khong_thuc_hien STRING, thoi_gian_xac_nhan_khong_thuc_hien STRING, khong_thuc_hien BOOLEAN,
                  ly_doi_khong_thuc_hien STRING, trang_thai_thong_bao STRING, thoi_gian_bat_dau STRING,
                  thoi_gian_hoan_thanh STRING, active BOOLEAN, deleted INT, created_at STRING,
                  updated_at STRING""";
        }
    }

    public static class CtKhamSucKhoeProcessor implements TableProcessor {
        @Override public String getSourceTableName() { return "ct_kham_suc_khoe"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  id INT, chuc_vu STRING, den_thoi_gian_kham STRING, den_thoi_gian_lay_mau STRING,
                  dia_diem_kham STRING, dia_diem_lay_mau STRING, ds_bo_chi_dinh_id STRING, ds_dich_vu_id STRING,
                  hinh_thuc_tt_dv_ngoai_hd FLOAT, hop_dong_ksk_id INT, ma_nhan_vien STRING, ngoai_vien BOOLEAN,
                  phong_ban STRING, stt INT, thoi_gian_hoan_thanh STRING, trang_thai INT,
                  tu_thoi_gian_kham STRING, tu_thoi_gian_lay_mau STRING, hinh_thuc_tt_dv_trong_hd FLOAT,
                  created_at STRING, updated_at STRING""";
        }
    }

    public static class CtNguonNbProcessor implements TableProcessor {
        @Override public String getSourceTableName() { return "ct_nguon_nb"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  nb_dot_dieu_tri_id INT, ghi_chu STRING, nguoi_gioi_thieu_id FLOAT, nguon_nb_id FLOAT,
                  created_at STRING, updated_at STRING""";
        }
    }

    public static class CtPhieuThuProcessor implements TableProcessor {
        @Override public String getSourceTableName() { return "ct_phieu_thu"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  id INT, active BOOLEAN, deleted INT, nb_dot_dieu_tri_id INT, ca_lam_viec_id FLOAT,
                  doi_tuong_kcb INT, ds_ma_giam_gia_id STRING, ghi_chu STRING, hinh_thuc_mien_giam FLOAT,
                  hoa_don_id STRING, ky_hieu STRING, loai_phieu_thu INT, nb_goi_dv_id STRING,
                  nha_thu_ngan_id FLOAT, nho_hon_muc_cung_chi_tra BOOLEAN, phan_tram_mien_giam FLOAT,
                  quay_id FLOAT, so_phieu INT, thanh_tien FLOAT, thanh_toan INT,
                  thoi_gian_huy_thanh_toan STRING, thoi_gian_thanh_toan STRING, thu_ngan_huy_thanh_toan_id FLOAT,
                  thu_ngan_id FLOAT, tien_bh_thanh_toan FLOAT, tien_bh_thanh_toan_trong_goi FLOAT,
                  tien_giam_gia FLOAT, tien_hoan_tra FLOAT, tien_mien_giam_dich_vu FLOAT,
                  tien_mien_giam_phieu_thu FLOAT, tien_mien_giam_phieu_thu_nhap_vao FLOAT,
                  tien_nb_cung_chi_tra FLOAT, tien_nb_cung_chi_tra_trong_goi FLOAT, tien_nb_phu_thu FLOAT,
                  tien_nb_tu_tra FLOAT, tien_nguon_khac FLOAT, tien_tai_tro_bao_hiem FLOAT,
                  tien_tai_tro_khong_bao_hiem FLOAT, trang_thai_hoa_don INT, hoan_ung BOOLEAN,
                  loai_mien_giam STRING, phieu_doi_tra_id STRING, thoi_gian_tao_phieu STRING,
                  thoi_gian_cap_nhat_phieu STRING, created_at STRING, updated_at STRING""";
        }
    }
    public static class HospitalConfigsProcessor implements TableProcessor {
        @Override public String getSourceTableName() { return "hospital_configs"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  id INT, table_name STRING, name STRING, value_code STRING,
                  description STRING, created_at STRING, updated_at STRING""";
        }
    }   
}