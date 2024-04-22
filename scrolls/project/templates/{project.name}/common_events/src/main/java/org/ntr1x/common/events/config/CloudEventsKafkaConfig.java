package org.ntr1x.common.events.config;

import io.cloudevents.CloudEvent;
import io.cloudevents.kafka.CloudEventDeserializer;
import io.cloudevents.kafka.CloudEventSerializer;
import lombok.RequiredArgsConstructor;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.apache.kafka.common.serialization.StringSerializer;
import org.ntr1x.common.events.CloudEventsConstants;
import org.springframework.boot.autoconfigure.kafka.KafkaProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.core.*;

@Configuration
@RequiredArgsConstructor
public class CloudEventsKafkaConfig {
    private final KafkaProperties kafkaProperties;

    @Bean(CloudEventsConstants.CONSUMER_FACTORY_CLOUD_EVENT)
    public ConsumerFactory<String, CloudEvent> cloudEventConsumerFactory() {
        return new DefaultKafkaConsumerFactory<>(
                kafkaProperties.buildConsumerProperties(),
                new StringDeserializer(),
                new CloudEventDeserializer()
        );
    }

    @Bean(CloudEventsConstants.PRODUCER_FACTORY_CLOUD_EVENT)
    public ProducerFactory<String, CloudEvent> cloudEventProducerFactory() {
        return new DefaultKafkaProducerFactory<>(
                kafkaProperties.buildProducerProperties(),
                new StringSerializer(),
                new CloudEventSerializer()
        );
    }

    @Bean(CloudEventsConstants.KAFKA_TEMPLATE_CLOUD_EVENT)
    public KafkaTemplate<String, CloudEvent> cloudEventKafkaTemplate() {
        return new KafkaTemplate<>(cloudEventProducerFactory());
    }
}
