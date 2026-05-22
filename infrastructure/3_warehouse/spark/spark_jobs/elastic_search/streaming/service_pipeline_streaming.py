from elastic_streaming import ElasticStreaming


class ServicePipelineStreaming(ElasticStreaming):
    def __init__(self):
        super().__init__("dm_dich_vu", "idx_dich_vu", "code_dichvu")

    def extract_stream(self):
        return self.spark.readStream \
            .format("iceberg") \
            .load(f"{self.source_sink}.{self.source}")

    def transform(self, df):
        return df.select(
            "id",
            "code_dichvu",
            "ten",
            "ten_tuong_duong",
            "viet_tat",
            "gia_bao_hiem",
            "gia_khong_bao_hiem",
            "loai_dich_vu",
            "active"
        )


if __name__ == "__main__":
    job = ServicePipelineStreaming()
    job.spark.sparkContext.setLogLevel("ERROR")
    job.run()
    try:
        job.spark.stop()
    except Exception:
        pass
