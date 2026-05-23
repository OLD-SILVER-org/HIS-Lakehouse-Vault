package core;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import JobConfig;

public class SlackWebhookSender {

    private static final String WEBHOOK_URL = JobConfig.get("slack.webhook.url");

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
    public static void main(String[] args) {
        sendMessage("Hello from Java.");
    }
}