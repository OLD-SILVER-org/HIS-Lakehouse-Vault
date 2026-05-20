from elastic_batch import ElasticBatch

class PatientPipelineBatch(ElasticBatch):
    def __init__(self):
        super().__init__("dm_benh_nhan", "idx_benh_nhan", "ma_nb")
        
    def extract(self):
        query = f"""
            SELECT 
                nb_thong_tin_id, 
                ma_nb, 
                so_dien_thoai, 
                ten_nb, 
                ten_nb_khong_dau 
            FROM {self.source_sink}.{self.source}
        """
        return self.spark.sql(query)

    def transform(self, df):
        return df
    
if __name__ == "__main__":
    job = PatientPipelineBatch()
    job.run()
    
