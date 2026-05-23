package core;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;


public final class JobConfig {

    private static final Properties properties = new Properties();
    private static final String CONFIG_FILE = "flink-job.properties";
    private static final String SECRET_CONFIG_FILE = "secret.properties";

    static {
        // Load cấu hình thông thường (Bắt buộc)
        loadProperties(CONFIG_FILE, true);
        // Load cấu hình bảo mật (Bắt buộc để đảm bảo "kiểm soát" như bạn muốn)
        loadProperties(SECRET_CONFIG_FILE, true);
    }

    private JobConfig() {}

    private static void loadProperties(String fileName, boolean mandatory) {
        try (InputStream input = JobConfig.class.getClassLoader().getResourceAsStream(fileName)) {
            if (input == null) {
                if (mandatory) {
                    throw new RuntimeException("Missing mandatory config file: " + fileName);
                }
                return;
            }
            properties.load(input);
        } catch (IOException ex) {
            throw new RuntimeException("Failed to load config file: " + fileName, ex);
        }
    }

    public static String get(String key) {
        String value = properties.getProperty(key);
        if (value == null) {
            throw new NullPointerException("Cant find key: '" + key + "' in " + CONFIG_FILE);
        }
        return value;
    }

    public static String get(String key, String defaultValue) {
        return properties.getProperty(key, defaultValue);
    }
}