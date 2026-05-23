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
                String errorMessage = "Cant find config file '" + CONFIG_FILE + "' in classpath.";
                System.err.println(errorMessage);
                throw new RuntimeException(errorMessage);
            }
            properties.load(input);
        } catch (IOException ex) {
            String errorMessage = "Cant load config file '" + CONFIG_FILE + "'.";
            System.err.println(errorMessage);
            ex.printStackTrace();
            throw new RuntimeException(errorMessage, ex);
        }
    }

    private JobConfig() {}

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