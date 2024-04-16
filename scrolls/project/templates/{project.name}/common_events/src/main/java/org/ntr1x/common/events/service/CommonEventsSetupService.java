package org.ntr1x.common.events.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.cloudevents.CloudEvent;
import org.ntr1x.common.events.CommonEventsConstants;
import org.ntr1x.common.events.model.CloudEventTemplate;
import org.ntr1x.common.events.model.KafkaListenerConfigModel;
import org.ntr1x.common.events.model.KafkaTopicConfigModel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.autoconfigure.kafka.KafkaProperties;
import org.springframework.kafka.core.ConsumerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.listener.ConcurrentMessageListenerContainer;
import org.springframework.kafka.listener.ContainerProperties;
import org.springframework.kafka.listener.GenericMessageListener;
import org.springframework.kafka.listener.GenericMessageListenerContainer;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.util.Optional;

@Service
public class CommonEventsSetupService {
    @Autowired
    private ObjectMapper objectMapper;
    @Autowired
    private KafkaProperties kafkaProperties;
    @Autowired
    @Qualifier(CommonEventsConstants.KAFKA_TEMPLATE_CLOUD_EVENT)
    private KafkaTemplate<String, CloudEvent> cloudEventKafkaTemplate;
    @Autowired
    @Qualifier(CommonEventsConstants.CONSUMER_FACTORY_CLOUD_EVENT)
    private ConsumerFactory<String, CloudEvent> cloudEventConsumerFactory;

    public GenericMessageListenerContainer<String, CloudEvent> setupContainer(
            KafkaListenerConfigModel config,
            GenericMessageListener messageListener
    ) {
        String consumerGroupId = Optional
                .ofNullable((String) null)
                .or(() -> Optional.ofNullable(config.getGroupId()))
                .or(() -> Optional.ofNullable(kafkaProperties.getConsumer().getGroupId()))
                .orElseThrow();

        String clientId = Optional
                .ofNullable((String) null)
                .or(() -> Optional.ofNullable(config.getClientId()))
                .or(() -> Optional.ofNullable(kafkaProperties.getConsumer().getClientId()))
                .orElseThrow();

        ContainerProperties containerProperties = Optional
                .ofNullable((ContainerProperties) null)
                .or(() -> Optional.ofNullable(config.getTopicPattern()).map(ContainerProperties::new))
                .or(() -> Optional.ofNullable(config.getTopics()).map(ContainerProperties::new))
                .or(() -> Optional.ofNullable(config.getTopic()).map(ContainerProperties::new))
                .orElseThrow();

        ContainerProperties.AckMode ackMode = Optional
                .ofNullable((ContainerProperties.AckMode) null)
                .or(() -> Optional.ofNullable(config.getAckMode()))
                .orElse(ContainerProperties.AckMode.BATCH);

        containerProperties.setGroupId(consumerGroupId);
        containerProperties.setClientId(clientId);
        containerProperties.setAckMode(ackMode);
        containerProperties.setMessageListener(messageListener);

        ConcurrentMessageListenerContainer<String, CloudEvent> container =
                new ConcurrentMessageListenerContainer<>(cloudEventConsumerFactory, containerProperties);

        Integer concurrency = Optional
                .ofNullable(config.getConcurrency())
                .orElse(1);

        container.setConcurrency(concurrency);

        return container;
    }

    public CloudEventTemplate setupTemplate(KafkaTopicConfigModel topic, URI source) {
        return CloudEventTemplate
                .builder()
                .objectMapper(objectMapper)
                .kafkaTemplate(cloudEventKafkaTemplate)
                .topic(topic.getName())
                .type("request")
                .source(source)
                .build();
    }
}
