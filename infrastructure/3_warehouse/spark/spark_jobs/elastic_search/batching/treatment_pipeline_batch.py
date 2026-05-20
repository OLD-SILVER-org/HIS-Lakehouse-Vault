from elastic_batch import ElasticBatch

class TreatmentPipelineBatch(ElasticBatch):
    def __init__(self):
        super().__init__("ct_dot_dieu_tri", "idx_dot_dieu_tri", "id")
        
    def extract(self):
        query = f"""
            SELECT 
                id, 
                cap_cuu, 
                doi_tuong, 
                doi_tuong_kcb, 
                email, 
                gioi_tinh, 
                kham_suc_khoe, 
                khoa_id, 
                khoa_tiep_don_id, 
                loai_benh_an_id, 
                loai_doi_tuong_id, 
                ma_benh_an, 
                ma_ho_so, 
                ma_nb, 
                nb_thong_tin_id, 
                ngay_sinh, 
                so_bao_hiem_xa_hoi, 
                so_dien_thoai, 
                so_ngay_dieu_tri, 
                so_phoi, 
                ten_nb, 
                ten_nb_khong_dau, 
                thoi_gian_lap_benh_an, 
                thoi_gian_ra_vien, 
                thoi_gian_vao_vien, 
                trang_thai, 
                uu_tien
            FROM {self.source_sink}.{self.source}
        """
        return self.spark.sql(query)

    def transform(self, df):
        return df
    
if __name__ == "__main__":
    job = TreatmentPipelineBatch()
    job.run()
