from elastic_streaming import ElasticStreaming


class PatientPipelineStreaming(ElasticStreaming):
    def __init__(self):
        super().__init__("dm_benh_nhan", "idx_benh_nhan", "ma_nb")

    def extract_stream(self):
        return self.spark.readStream \
            .format("iceberg") \
            .load(f"{self.source_sink}.{self.source}")

    def transform(self, df):
        return df.select(
            "nb_thong_tin_id",
            "ma_nb",
            "so_dien_thoai",
            "ten_nb",
            "ten_nb_khong_dau"
        )


if __name__ == "__main__":
    job = PatientPipelineStreaming()
    job.spark.sparkContext.setLogLevel("ERROR")
    job.run()
    try:
        job.spark.stop()
    except Exception:
        pass
