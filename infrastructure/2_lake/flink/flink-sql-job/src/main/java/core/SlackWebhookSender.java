package core;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

import java.io.InputStream;
import java.util.Properties;

public class SlackWebhookSender {

    private static final String WEBHOOK_URL = System.getenv("SLACK_WEBHOOK_URL") != null ? System.getenv("SLACK_WEBHOOK_URL") : loadWebhookFromProperties();

    public static void sendMessage(String message) {
        try {
            URL url = new URL(WEBHOOK_URL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setRequestProperty("Content-Type", "application/json");

            String payload = "{\"text\": \"" + message + "\"}";

            try (OutputStream os = conn.getOutputStream()) {
                os.write(payload.getBytes("utf-8"));
            }

            int responseCode = conn.getResponseCode();
            System.out.println("Slack response code: " + responseCode);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Demo
    private static String loadWebhookFromProperties() {
        try (InputStream input = SlackWebhookSender.class.getClassLoader().getResourceAsStream("slack.properties")) {
            if (input == null) {
                System.err.println("Slack properties file not found. Using empty webhook URL.");
                return "";
            }
            Properties prop = new Properties();
            prop.load(input);
            return prop.getProperty("slack.webhook.url", "");
        } catch (Exception e) {
            e.printStackTrace();
            return "";
        }
    }

        sendMessage("Xin chào từ Java! Đây là tin nhắn demo gửi đến Slack.");
    }
}