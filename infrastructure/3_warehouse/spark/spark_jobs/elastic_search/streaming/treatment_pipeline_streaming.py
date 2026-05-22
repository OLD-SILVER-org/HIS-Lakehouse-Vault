from elastic_streaming import ElasticStreaming


class TreatmentPipelineStreaming(ElasticStreaming):
    def __init__(self):
        super().__init__("ct_dot_dieu_tri", "idx_dot_dieu_tri", "id")

    def extract_stream(self):
        return self.spark.readStream \
            .format("iceberg") \
            .load(f"{self.source_sink}.{self.source}")

    def transform(self, df):
        return df.select(
            "id",
            "cap_cuu",
            "doi_tuong",
            "doi_tuong_kcb",
            "email",
            "gioi_tinh",
            "kham_suc_khoe",
            "khoa_id",
            "khoa_tiep_don_id",
            "loai_benh_an_id",
            "loai_doi_tuong_id",
            "ma_benh_an",
            "ma_ho_so",
            "ma_nb",
            "nb_thong_tin_id",
            "ngay_sinh",
            "so_bao_hiem_xa_hoi",
            "so_dien_thoai",
            "so_ngay_dieu_tri",
            "so_phoi",
            "ten_nb",
            "ten_nb_khong_dau",
            "thoi_gian_lap_benh_an",
            "thoi_gian_ra_vien",
            "thoi_gian_vao_vien",
            "trang_thai",
            "uu_tien"
        )


if __name__ == "__main__":
    job = TreatmentPipelineStreaming()
    job.spark.sparkContext.setLogLevel("ERROR")
    job.run()
    try:
        job.spark.stop()
    except Exception:
        pass
