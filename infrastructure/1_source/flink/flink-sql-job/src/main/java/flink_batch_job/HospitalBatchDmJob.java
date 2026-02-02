package flink_batch_job;

import core.DmProcessor;
import core.TableProcessor;

import java.util.HashMap;
import java.util.Map;

/**
 * Flink batch job to process all 'dm_*' (dictionary/master) related tables for initial data ingestion.
 */
public class HospitalBatchDmJob extends AbstractBatchBase {

    @Override
    protected Map<String, TableProcessor> getTableProcessors() {
        Map<String, TableProcessor> processors = new HashMap<>();
        processors.put("dm_benh_nhan", new DmProcessor.DmBenhNhanProcessor());
        processors.put("dm_bo_chi_dinh", new DmProcessor.DmBoChiDinhProcessor());
        processors.put("dm_chuyen_khoa", new DmProcessor.DmChuyenKhoaProcessor());
        processors.put("dm_dich_vu", new DmProcessor.DmDichVuProcessor());
        processors.put("dm_doi_tuong_kcb", new DmProcessor.DmDoiTuongKcbProcessor());
        processors.put("dm_dv_discount", new DmProcessor.DmDvDiscountProcessor());
        processors.put("dm_hoc_ham_hoc_vi", new DmProcessor.DmHocHamHocViProcessor());
        processors.put("dm_hop_dong_ksk", new DmProcessor.DmHopDongKskProcessor());
        processors.put("dm_loai_dich_vu", new DmProcessor.DmLoaiDichVuProcessor());
        processors.put("dm_khoa", new DmProcessor.DmKhoaProcessor());
        processors.put("dm_nguoi_gioi_thieu", new DmProcessor.DmNguoiGioiThieuProcessor());
        processors.put("dm_nguon_nb", new DmProcessor.DmNguonNbProcessor());
        processors.put("dm_nhan_vien", new DmProcessor.DmNhanVienProcessor());
        processors.put("dm_nhom_dich_vu_cap1", new DmProcessor.DmNhomDichVuCap1Processor());
        processors.put("dm_nhom_dich_vu_cap2", new DmProcessor.DmNhomDichVuCap2Processor());
        processors.put("dm_nhom_dich_vu_cap3", new DmProcessor.DmNhomDichVuCap3Processor());
        processors.put("dm_phong", new DmProcessor.DmPhongProcessor());
        processors.put("dm_quan_huyen", new DmProcessor.DmQuanHuyenProcessor());
        processors.put("dm_tinh_thanh_pho", new DmProcessor.DmTinhThanhPhoProcessor());
        processors.put("dm_xa_phuong", new DmProcessor.DmXaPhuongProcessor());
        return processors;
    }

    public static void main(String[] args) throws Exception {
        System.out.println("Starting Hospital Flink Batch Job for DM (Dictionary/Master) tables...");
        HospitalBatchDmJob job = new HospitalBatchDmJob();
        job.run();
    }
}