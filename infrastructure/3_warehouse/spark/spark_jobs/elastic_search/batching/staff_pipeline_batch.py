from elastic_batch import ElasticBatch

class StaffPipelineBatch(ElasticBatch):
    def __init__(self):
        # Truyền 3 tham số: source, target_index, id_col
        super().__init__("dm_nhan_vien", "idx_nhan_vien", "code_nhan_vien")
        
    def extract(self):
        query = f"""
            SELECT 
                id, 
                code_nhan_vien, 
                ten, 
                chung_chi, 
                ds_chuyen_khoa_id, 
                email, 
                gioi_tinh, 
                hoc_ham_hoc_vi_id, 
                ngay_sinh, 
                van_bang_id, 
                active
            FROM {self.source_sink}.{self.source}
        """
        return self.spark.sql(query)

    def transform(self, df):
        return df
    
if __name__ == "__main__":
    job = StaffPipelineBatch()
    job.run()
