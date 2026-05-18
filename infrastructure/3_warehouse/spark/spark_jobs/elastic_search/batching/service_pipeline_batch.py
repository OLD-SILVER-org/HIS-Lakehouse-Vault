from elastic_batch import ElasticBatch

class ServicePipelineBatch(ElasticBatch):
    def __init__(self):
        # Truyền 3 tham số: source, target_index, id_col
        super().__init__("dm_dich_vu", "idx_dich_vu", "code_dichvu")
        
    def extract(self):
        query = f"""
            SELECT 
                id, 
                code_dichvu, 
                ten, 
                ten_tuong_duong, 
                viet_tat, 
                gia_bao_hiem, 
                gia_khong_bao_hiem, 
                loai_dich_vu, 
                active
            FROM {self.source_sink}.{self.source}
        """
        return self.spark.sql(query)

    def transform(self, df):
        return df
    
if __name__ == "__main__":
    job = ServicePipelineBatch()
    job.run()
