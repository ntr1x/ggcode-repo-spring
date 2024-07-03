package org.ntr1x.common.ws.model;

import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonTypeInfo;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.ntr1x.common.ws.service.SocketHubService;

import java.util.Collection;
import java.util.Map;
import java.util.Optional;

@JsonTypeInfo(use = JsonTypeInfo.Id.NAME)
@JsonSubTypes({
        @JsonSubTypes.Type(value = SocketOutgoingMessage.MESSAGE.class, name = "MESSAGE"),
        @JsonSubTypes.Type(value = SocketOutgoingMessage.SUBSCRIBED.class, name = "SUBSCRIBED"),
        @JsonSubTypes.Type(value = SocketOutgoingMessage.UNSUBSCRIBED.class, name = "UNSUBSCRIBED"),
        @JsonSubTypes.Type(value = SocketOutgoingMessage.DESCRIBE.class, name = "DESCRIBE"),
        @JsonSubTypes.Type(value = SocketOutgoingMessage.LIST.class, name = "LIST"),
        @JsonSubTypes.Type(value = SocketOutgoingMessage.HELLO.class, name = "HELLO"),
        @JsonSubTypes.Type(value = SocketOutgoingMessage.FAILURE.class, name = "FAILURE"),
})
public interface SocketOutgoingMessage {
    @Data
    @Builder
    @RequiredArgsConstructor
    class MESSAGE implements SocketOutgoingMessage {
        private final Map<String, String> attributes;
        private final Object payload;
    }

    @Data
    @Builder
    @RequiredArgsConstructor
    class FAILURE implements SocketOutgoingMessage {
        private final Optional<String> messageId;
        private final String reason;
    }

    @Data
    @Builder
    @RequiredArgsConstructor
    class SUBSCRIBED implements SocketOutgoingMessage {
        private final String sessionId;
        private final Optional<String> messageId;
        private final String subscriptionId;
    }

    @Data
    @Builder
    @RequiredArgsConstructor
    class UNSUBSCRIBED implements SocketOutgoingMessage {
        private final String sessionId;
        private final Optional<String> messageId;
        private final String subscriptionId;
    }

    @Data
    @Builder
    @RequiredArgsConstructor
    class DESCRIBE implements SocketOutgoingMessage {
        private final String sessionId;
        private final String subscriptionId;
        private final Optional<String> messageId;
        private final SocketHubService.SocketSubscription subscription;
    }

    @Data
    @Builder
    @RequiredArgsConstructor
    class LIST implements SocketOutgoingMessage {
        private final String sessionId;
        private final Optional<String> messageId;
        private final Collection<String> subscriptions;
    }

    @Data
    @Builder
    @RequiredArgsConstructor
    class HELLO implements SocketOutgoingMessage {
        private final String sessionId;
        private final Optional<String> messageId;
        private final String message;
    }
}