package core;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;


public final class JobConfig {

    private static final Properties properties = new Properties();
    private static final String CONFIG_FILE = "flink-job.properties";

    static {
        try (InputStream input = JobConfig.class.getClassLoader().getResourceAsStream(CONFIG_FILE)) {
            if (input == null) {
                String errorMessage = "Không thể tìm thấy tệp cấu hình '" + CONFIG_FILE + "' trong classpath.";
                System.err.println(errorMessage);
                throw new RuntimeException(errorMessage);
            }
            properties.load(input);
        } catch (IOException ex) {
            String errorMessage = "Lỗi khi tải tệp cấu hình '" + CONFIG_FILE + "'.";
            System.err.println(errorMessage);
            ex.printStackTrace();
            throw new RuntimeException(errorMessage, ex);
        }
    }

    private JobConfig() {}

    public static String get(String key) {
        String value = properties.getProperty(key);
        if (value == null) {
            throw new NullPointerException("Không tìm thấy thuộc tính cấu hình bắt buộc: '" + key + "' trong " + CONFIG_FILE);
        }
        return value;
    }

    public static String get(String key, String defaultValue) {
        return properties.getProperty(key, defaultValue);
    }
}