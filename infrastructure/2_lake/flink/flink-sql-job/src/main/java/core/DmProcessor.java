package core;

/**
 * A container class for TableProcessor implementations related to 'dm_*' (dictionary/master) tables
 * for batch processing.
 */
public class DmProcessor {

    private DmProcessor() {
        // Private constructor to prevent instantiation
    }

    public static class DmBenhNhanProcessor implements TableProcessor {
        @Override public String getSourceTableName() { return "dm_benh_nhan"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  nb_thong_tin_id INT, ma_nb BIGINT, email STRING, ngay_sinh STRING,
                  noi_lam_viec STRING, so_dien_thoai STRING, ten_nb STRING, ten_nb_khong_dau STRING,
                  created_at STRING, updated_at STRING""";
        }
    }

    public static class DmBoChiDinhProcessor implements TableProcessor {
        @Override public String getSourceTableName() { return "dm_bo_chi_dinh"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  id INT, code_bo_chi_dinh STRING, ten STRING, ds_bac_si_chi_dinh_id STRING,
                  ds_doi_tuong_su_dung STRING, ds_kho_id STRING, ds_loai_dich_vu STRING,
                  han_che_khoa_chi_dinh BOOLEAN, hop_dong_ksk_id FLOAT, thuoc_chi_dinh_ngoai BOOLEAN,
                  ket_qua_lau BOOLEAN, active BOOLEAN, deleted INT, created_at STRING,
                  updated_at STRING""";
        }
    }

    public static class DmChuyenKhoaProcessor implements TableProcessor {
        @Override public String getSourceTableName() { return "dm_chuyen_khoa"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  id INT, ten STRING, code_chuyen_khoa STRING, active BOOLEAN, deleted INT,
                  created_at STRING, updated_at STRING""";
        }
    }

    public static class DmDichVuProcessor implements TableProcessor {
        @Override public String getSourceTableName() { return "dm_dich_vu"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  id INT, code_dichvu STRING, ten STRING, don_vi_tinh_id FLOAT,
                  ds_nguon_khac_chi_tra STRING, gia_bao_hiem STRING, gia_khong_bao_hiem FLOAT,
                  khong_tinh_tien FLOAT, loai_dich_vu INT, nhom_dich_vu_cap1_id INT,
                  nhom_dich_vu_cap2_id FLOAT, nhom_dich_vu_cap3_id FLOAT, ten_tuong_duong STRING,
                  thu_ngoai BOOLEAN, ty_le_bh_tt INT, ty_le_tt_dv INT, viet_tat STRING,
                  chi_dinh_sl_le BOOLEAN, nguon_khac_id STRING, gui_vitimes BOOLEAN,
                  mien_phi_giam_doc_duyet BOOLEAN, khong_su_dung BOOLEAN, online_ BOOLEAN,
                  sua_gia BOOLEAN, active BOOLEAN, deleted INT, created_at STRING,
                  updated_at STRING""";
        }
    }

    public static class DmDoiTuongKcbProcessor implements TableProcessor {
        @Override public String getSourceTableName() { return "dm_doi_tuong_kcb"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  id INT, ten STRING, created_at STRING, updated_at STRING""";
        }
    }

    public static class DmDvDiscountProcessor implements TableProcessor {
        @Override public String getSourceTableName() { return "dm_dv_discount"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  id INT, discount_percent FLOAT, loai_dich_vu_id STRING, type_discount INT,
                  fix_amount BIGINT, created_at STRING, updated_at STRING""";
        }
    }

    public static class DmHocHamHocViProcessor implements TableProcessor {
        @Override public String getSourceTableName() { return "dm_hoc_ham_hoc_vi"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  id INT, code_hoc_ham STRING, ten STRING, active BOOLEAN, deleted INT,
                  created_at STRING, updated_at STRING""";
        }
    }

    public static class DmHopDongKskProcessor implements TableProcessor {
        @Override public String getSourceTableName() { return "dm_hop_dong_ksk"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  id INT, code_hop_dong INT, ten STRING, ds_ma_giam_gia_id STRING,
                  hinh_thuc_mien_giam FLOAT, hinh_thuc_tt_dv_ngoai_hd FLOAT, ngay_hieu_luc STRING,
                  phan_tram_mien_giam FLOAT, so_hop_dong STRING, thoi_gian_thanh_ly STRING,
                  tien_chua_thanh_toan FLOAT, tien_da_thanh_toan FLOAT, tien_du_kien FLOAT,
                  tien_du_kien_sau_giam FLOAT, tien_giam_gia FLOAT, tien_mien_giam_dich_vu FLOAT,
                  tien_mien_giam_hop_dong FLOAT, tien_thuc_te FLOAT, tien_thuc_te_sau_giam FLOAT,
                  trang_thai INT, chot_thanh_toan_dv_ksk FLOAT, tien_nb_da_thanh_toan FLOAT,
                  tien_tai_tro_nb FLOAT, nguoi_gioi_thieu_id FLOAT, nguon_nb_id FLOAT,
                  active BOOLEAN, deleted INT, created_at STRING, updated_at STRING""";
        }
    }

    public static class DmKhoaProcessor implements TableProcessor {
        @Override public String getSourceTableName() { return "dm_khoa"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  id INT, code_khoa STRING, ten STRING, ds_tinh_chat_khoa STRING, active BOOLEAN,
                  deleted INT, created_at STRING, updated_at STRING""";
        }
    }

    public static class DmLoaiDichVuProcessor implements TableProcessor {
        @Override public String getSourceTableName() { return "dm_loai_dich_vu"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  id INT, ten STRING, created_at STRING, updated_at STRING""";
        }
    }

    public static class DmNguoiGioiThieuProcessor implements TableProcessor {
        @Override public String getSourceTableName() { return "dm_nguoi_gioi_thieu"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  id INT, code_nguoi_gioi_thieu STRING, ten STRING, ds_nguon_nb_id STRING,
                  active BOOLEAN, deleted INT, created_at STRING, updated_at STRING""";
        }
    }

    public static class DmNguonNbProcessor implements TableProcessor {
        @Override public String getSourceTableName() { return "dm_nguon_nb"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  id INT, code_nguon_nb STRING, ten STRING, nguoi_gioi_thieu BOOLEAN,
                  nhom_nguon INT, active BOOLEAN, deleted INT, created_at STRING,
                  updated_at STRING""";
        }
    }

    public static class DmNhanVienProcessor implements TableProcessor {
        @Override public String getSourceTableName() { return "dm_nhan_vien"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  id INT, code_nhan_vien STRING, ten STRING, chung_chi STRING,
                  ds_chuyen_khoa_id STRING, email STRING, gioi_tinh STRING, hoc_ham_hoc_vi_id INT,
                  ngay_sinh STRING, van_bang_id INT, active BOOLEAN, deleted INT,
                  created_at STRING, updated_at STRING""";
        }
    }

    public static class DmNhomDichVuCap1Processor implements TableProcessor {
        @Override public String getSourceTableName() { return "dm_nhom_dich_vu_cap1"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  id INT, code_service_lvl_1 STRING, ten STRING, loai_dich_vu FLOAT,
                  stt_bang_ke INT, trang_thai_hoan_thanh FLOAT, trang_thai_lay_stt FLOAT,
                  active BOOLEAN, deleted INT, created_at STRING, updated_at STRING""";
        }
    }

    public static class DmNhomDichVuCap2Processor implements TableProcessor {
        @Override public String getSourceTableName() { return "dm_nhom_dich_vu_cap2"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  id INT, code_service_lvl_2 STRING, ten STRING, luu_phim_chup BOOLEAN,
                  nhom_dich_vu_cap1_id INT, phieu_chi_dinh_id FLOAT, tach_stt_noi_tru BOOLEAN,
                  tach_stt_uu_tien BOOLEAN, theo_yeu_cau BOOLEAN, tiep_don_cls BOOLEAN,
                  trang_thai_hoan_thanh FLOAT, trang_thai_lay_stt FLOAT, active BOOLEAN,
                  deleted INT, created_at STRING, updated_at STRING""";
        }
    }

    public static class DmNhomDichVuCap3Processor implements TableProcessor {
        @Override public String getSourceTableName() { return "dm_nhom_dich_vu_cap3"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  id INT, code_service_lvl_3 STRING, ten STRING, nhom_dich_vu_cap2_id INT,
                  active BOOLEAN, deleted INT, created_at STRING, updated_at STRING""";
        }
    }

    public static class DmPhongProcessor implements TableProcessor {
        @Override public String getSourceTableName() { return "dm_phong"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  id INT, code_phong STRING, ten STRING, chuyen_khoa_id FLOAT, dia_diem STRING,
                  ds_loai_phong STRING, khoa_id INT, ngoai_tru BOOLEAN, ngoai_vien BOOLEAN,
                  noi_tru BOOLEAN, online BOOLEAN, active BOOLEAN, deleted INT,
                  created_at STRING, updated_at STRING""";
        }
    }

    public static class DmQuanHuyenProcessor implements TableProcessor {
        @Override public String getSourceTableName() { return "dm_quan_huyen"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  id INT, ten STRING, code_quan_huyen INT, ma_tcqg INT, tinh_thanh_pho_id INT,
                  active BOOLEAN, deleted INT, created_at STRING, updated_at STRING""";
        }
    }

    public static class DmTinhThanhPhoProcessor implements TableProcessor {
        @Override public String getSourceTableName() { return "dm_tinh_thanh_pho"; }
        @Override public String getPartitionKey() { return "partition_col"; }
        @Override public String getTableSchemaDDL() {
            return """
                  id INT, code_province INT, ten STRING, ma_tcqg INT, active BOOLEAN,
                  deleted INT, created_at STRING, updated_at STRING""";
        }
    }

    public static class DmXaPhuongProcessor implements TableProcessor {
        @Override public String getSourceTableName() { return "dm_xa_phuong"; }
        @Override public String getPartitionKey() { return "quan_huyen_id"; }
        @Override public String getTableSchemaDDL() {
            return """
                  xa_phuong_id INT, ten_xa_phuong STRING, quan_huyen_id INT""";
        }
    }
}