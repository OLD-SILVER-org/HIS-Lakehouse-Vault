package flink_batch_job;

import core.CtProcessor;
import core.TableProcessor;
import java.util.HashMap;
import java.util.Map;

/**
 * Flink job to process all 'ct_*' (clinical trial) related tables.
 */
public class HospitalBatchCtJob extends AbstractBatchBase {

    @Override
    protected Map<String, TableProcessor> getTableProcessors() {
        Map<String, TableProcessor> processors = new HashMap<>();
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
        System.out.println("Starting Hospital Flink Job for CT (Clinical Trial) tables...");
        HospitalBatchCtJob job = new HospitalBatchCtJob();
        job.run();
    }

}