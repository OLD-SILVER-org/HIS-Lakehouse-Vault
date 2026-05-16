from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("TestJob").getOrCreate()
data = spark.range(1, 1000)
print("Count:", data.count())
spark.stop()
