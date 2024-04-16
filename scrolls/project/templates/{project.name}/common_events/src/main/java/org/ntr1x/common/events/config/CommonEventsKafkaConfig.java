package org.ntr1x.common.events.config;

import io.cloudevents.CloudEvent;
import io.cloudevents.kafka.CloudEventDeserializer;
import io.cloudevents.kafka.CloudEventSerializer;
import lombok.RequiredArgsConstructor;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.apache.kafka.common.serialization.StringSerializer;
import org.ntr1x.common.events.CommonEventsConstants;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.boot.autoconfigure.kafka.KafkaProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.kafka.core.*;

@AutoConfiguration
@RequiredArgsConstructor
public class CommonEventsKafkaConfig {
    private final KafkaProperties kafkaProperties;

    @Bean(CommonEventsConstants.CONSUMER_FACTORY_CLOUD_EVENT)
    public ConsumerFactory<String, CloudEvent> cloudEventConsumerFactory() {
        return new DefaultKafkaConsumerFactory<>(
                kafkaProperties.buildConsumerProperties(),
                new StringDeserializer(),
                new CloudEventDeserializer()
        );
    }

    @Bean(CommonEventsConstants.PRODUCER_FACTORY_CLOUD_EVENT)
    public ProducerFactory<String, CloudEvent> cloudEventProducerFactory() {
        return new DefaultKafkaProducerFactory<>(
                kafkaProperties.buildProducerProperties(),
                new StringSerializer(),
                new CloudEventSerializer()
        );
    }

    @Bean(CommonEventsConstants.KAFKA_TEMPLATE_CLOUD_EVENT)
    public KafkaTemplate<String, CloudEvent> cloudEventKafkaTemplate() {
        return new KafkaTemplate<>(cloudEventProducerFactory());
    }
}
