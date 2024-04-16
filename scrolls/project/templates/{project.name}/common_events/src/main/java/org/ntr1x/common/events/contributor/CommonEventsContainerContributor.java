package org.ntr1x.common.events.contributor;

import org.springframework.kafka.listener.MessageListenerContainer;

import java.util.Map;

public interface CommonEventsContainerContributor {
    void addContainers(Map<String, MessageListenerContainer> containers);
}
