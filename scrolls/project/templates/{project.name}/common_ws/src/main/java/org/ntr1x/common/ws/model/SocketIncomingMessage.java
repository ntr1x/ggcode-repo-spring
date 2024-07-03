package org.ntr1x.common.ws.model;

import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonTypeInfo;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Collection;
import java.util.Optional;

@JsonTypeInfo(use = JsonTypeInfo.Id.NAME)
@JsonSubTypes({
        @JsonSubTypes.Type(value = SocketIncomingMessage.SUBSCRIBE.class, name = "SUBSCRIBE"),
        @JsonSubTypes.Type(value = SocketIncomingMessage.UNSUBSCRIBE.class, name = "UNSUBSCRIBE"),
        @JsonSubTypes.Type(value = SocketIncomingMessage.DESCRIBE.class, name = "DESCRIBE"),
        @JsonSubTypes.Type(value = SocketIncomingMessage.LIST.class, name = "LIST"),
        @JsonSubTypes.Type(value = SocketIncomingMessage.HELLO.class, name = "HELLO"),
})
public interface SocketIncomingMessage {

    Optional<String> getMessageId();

    @Data
    @NoArgsConstructor
    class SUBSCRIBE implements SocketIncomingMessage {
        private String subscriptionId;
        private Optional<String> messageId;
        private String accessToken;
        private Collection<MessageSelector> selectors;
    }

    @Data
    @NoArgsConstructor
    class UNSUBSCRIBE implements SocketIncomingMessage {
        private String subscriptionId;
        private Optional<String> messageId;
    }

    @Data
    @NoArgsConstructor
    class DESCRIBE implements SocketIncomingMessage {
        private String subscriptionId;
        private Optional<String> messageId;
    }

    @Data
    @NoArgsConstructor
    class LIST implements SocketIncomingMessage {
        private Optional<String> messageId;
    }

    @Data
    @NoArgsConstructor
    class HELLO implements SocketIncomingMessage {
        private Optional<String> messageId;
        private String message;
    }
}
