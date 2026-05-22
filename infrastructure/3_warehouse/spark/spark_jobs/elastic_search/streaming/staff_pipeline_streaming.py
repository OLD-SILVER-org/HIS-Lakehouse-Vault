from elastic_streaming import ElasticStreaming


class StaffPipelineStreaming(ElasticStreaming):
    def __init__(self):
        super().__init__("dm_nhan_vien", "idx_nhan_vien", "code_nhan_vien")

    def extract_stream(self):
        return self.spark.readStream \
            .format("iceberg") \
            .load(f"{self.source_sink}.{self.source}")

    def transform(self, df):
        return df.select(
            "id",
            "code_nhan_vien",
            "ten",
            "chung_chi",
            "ds_chuyen_khoa_id",
            "email",
            "gioi_tinh",
            "hoc_ham_hoc_vi_id",
            "ngay_sinh",
            "van_bang_id",
            "active"
        )


if __name__ == "__main__":
    job = StaffPipelineStreaming()
    job.spark.sparkContext.setLogLevel("ERROR")
    job.run()
    try:
        job.spark.stop()
    except Exception:
        pass
