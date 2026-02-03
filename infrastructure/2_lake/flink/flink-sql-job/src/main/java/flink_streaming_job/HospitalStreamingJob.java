package flink_streaming_job;

import core.CtProcessor;
import core.DmProcessor;
import core.TableProcessor;
import core.SlackWebhookSender;

import java.util.HashMap;
import java.util.Map;

/**
 * Flink streaming job to process all 'dm_*' and 'ct_*' tables.
 */
public class HospitalStreamingJob extends AbstractStreamingBase {

    @Override
    protected Map<String, TableProcessor> getTableProcessors() {
        Map<String, TableProcessor> processors = new HashMap<>();

        // Add all DM (Dictionary/Master) processors
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

        // Add all CT (Clinical Trial) processors
        processors.put("ct_address", new CtProcessor.CtAddressProcessor());
        processors.put("ct_bo_chi_dinh", new CtProcessor.CtBoChiDinhProcessor());
        processors.put("ct_dich_vu", new CtProcessor.CtDichVuProcessor());
        processors.put("ct_dot_dieu_tri", new CtProcessor.CtDotDieuTriProcessor());
        processors.put("ct_dv_kham", new CtProcessor.CtDvKhamProcessor());
        processors.put("ct_dv_kham_ket_luan", new CtProcessor.CtDvKhamKetLuanProcessor());
        processors.put("ct_dv_ky_thuat", new CtProcessor.CtDvKyThuatProcessor());
        processors.put("ct_kham_suc_khoe", new CtProcessor.CtKhamSucKhoeProcessor());
        processors.put("ct_nguon_nb", new CtProcessor.CtNguonNbProcessor());
        processors.put("ct_phieu_thu", new CtProcessor.CtPhieuThuProcessor());
        processors.put("hospital_configs", new CtProcessor.HospitalConfigsProcessor());

        return processors;
    }

    public static void main(String[] args) throws Exception {
        System.out.println("Starting Combined Hospital Flink Streaming Job for DM and CT tables...");
        HospitalStreamingJob job = new HospitalStreamingJob();
        try {
            job.run();
    }
        catch (Exception e) {
            SlackWebhookSender.sendMessage("❌  Flink job failed with exception: " + e.getMessage());
            throw e;
        }
    }

}