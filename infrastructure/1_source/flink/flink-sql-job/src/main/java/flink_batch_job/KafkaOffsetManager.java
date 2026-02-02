package flink_batch_job;

import org.apache.kafka.clients.admin.*;
import org.apache.kafka.common.TopicPartition;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

/**
 * A helper class to manage interactions with Kafka for fetching offsets.
 */
public class KafkaOffsetManager implements AutoCloseable {
    private final AdminClient adminClient;

    public KafkaOffsetManager(String bootstrapServers) {
        Properties props = new Properties();
        props.put(AdminClientConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        this.adminClient = AdminClient.create(props);
    }

    public Map<TopicPartition, Long> getOffsets(String topic, OffsetSpec spec) throws ExecutionException, InterruptedException {
        Map<TopicPartition, OffsetSpec> request = new HashMap<>();
        List<TopicPartition> partitions = getPartitionsForTopic(topic);
        for (TopicPartition tp : partitions) {
            request.put(tp, spec);
        }

        Map<TopicPartition, ListOffsetsResult.ListOffsetsResultInfo> resultInfos = adminClient.listOffsets(request).all().get();

        Map<TopicPartition, Long> offsets = new HashMap<>();
        for (Map.Entry<TopicPartition, ListOffsetsResult.ListOffsetsResultInfo> entry : resultInfos.entrySet()) {
            offsets.put(entry.getKey(), entry.getValue().offset());
        }
        return offsets;
    }

    private List<TopicPartition> getPartitionsForTopic(String topic) throws ExecutionException, InterruptedException {
        DescribeTopicsResult result = adminClient.describeTopics(Collections.singletonList(topic));
        TopicDescription topicDescription = result.allTopicNames().get().get(topic);
        if (topicDescription == null) {
            throw new RuntimeException("Topic not found: " + topic);
        }
        return topicDescription.partitions().stream()
                .map(p -> new TopicPartition(topic, p.partition()))
                .collect(Collectors.toList());
    }

    public String formatOffsets(Map<TopicPartition, Long> offsets) {
        return offsets.entrySet().stream()
                .map(e -> "partition:" + e.getKey().partition() + ",offset:" + e.getValue())
                .collect(Collectors.joining(";"));
    }

    @Override
    public void close() {
        if (adminClient != null) {
            adminClient.close();
        }
    }
}