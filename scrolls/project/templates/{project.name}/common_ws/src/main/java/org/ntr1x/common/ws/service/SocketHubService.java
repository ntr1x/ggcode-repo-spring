package org.ntr1x.common.ws.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Builder;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.beanutils.BeanUtils;
import org.ntr1x.common.web.security.JwtAuthoritiesExtractor;
import org.ntr1x.common.web.security.JwtExpressionRoot;
import org.ntr1x.common.ws.exception.SocketCommandException;
import org.ntr1x.common.ws.model.MessageSelector;
import org.ntr1x.common.ws.model.SocketIncomingMessage;
import org.ntr1x.common.ws.model.SocketOutgoingMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationConverter;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.stereotype.Service;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;

import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.util.*;
import java.util.function.Predicate;

@Slf4j
@Service
public class SocketHubService {

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private JwtDecoder jwtDecoder;

    private Map<String, SocketSession> bySessionId = Collections.synchronizedMap(new HashMap<>());

    public void attach(WebSocketSession session) {
        SocketSession subscription = SocketSession
                .builder()
                .session(session)
                .subscriptions(new LinkedHashMap<>())
                .build();

        bySessionId.put(session.getId(), subscription);
    }

    public SocketIncomingMessage decode(WebSocketSession session, String message) throws SocketCommandException {
        try {
            return objectMapper.readValue(message, SocketIncomingMessage.class);
        } catch (JsonProcessingException e) {
            throw new SocketCommandException(null, "Cannot parse command", e);
        }
    }

    public String encode(WebSocketSession session, SocketOutgoingMessage message) throws SocketCommandException {
        try {
            return objectMapper.writeValueAsString(message);
        } catch (JsonProcessingException e) {
            throw new SocketCommandException(null, "Cannot parse command", e);
        }
    }

    public SocketSession detach(WebSocketSession session) {
        return bySessionId.remove(session.getId());
    }

    public void dispatch(SocketOutgoingMessage.MESSAGE message, Predicate<JwtExpressionRoot> checker) {
        Collection<SocketSession> affectedSubscriptions = new LinkedList<>();

        synchronized (bySessionId) {
            for (SocketSession subscription : bySessionId.values()) {

                for (SocketSubscription entry : subscription.subscriptions.values()) {
                    JwtExpressionRoot securityExpressionRoot = new JwtExpressionRoot(entry.getAuthentication());
                    for (MessageSelector selector : entry.getSelectors()) {

                        boolean isAllowed = checker.test(securityExpressionRoot);
                        boolean isMatched = isAllowed;

                        Map<String, MessageSelector.Filter> attributeFilters = selector.getHeaders();
                        Map<String, MessageSelector.Filter> propertyFilters = selector.getProperties();

                        if (isMatched && attributeFilters != null) {
                            for (Map.Entry<String, MessageSelector.Filter> filterEntry : attributeFilters.entrySet()) {
                                String name = filterEntry.getKey();
                                MessageSelector.Filter filter = filterEntry.getValue();
                                try {
                                    String value = BeanUtils.getNestedProperty(message.getAttributes(), name);
                                    if (!filter.match(value)) {
                                        isMatched = false;
                                        break;
                                    }
                                } catch (IllegalAccessException e) {
                                    throw new RuntimeException(e);
                                } catch (InvocationTargetException e) {
                                    throw new RuntimeException(e);
                                } catch (NoSuchMethodException e) {
                                    throw new RuntimeException(e);
                                }
                            }
                        }

                        if (isMatched && propertyFilters != null) {
                            for (Map.Entry<String, MessageSelector.Filter> filterEntry : propertyFilters.entrySet()) {
                                String name = filterEntry.getKey();
                                MessageSelector.Filter filter = filterEntry.getValue();
                                try {
                                    String value = BeanUtils.getNestedProperty(message.getPayload(), name);
                                    if (!filter.match(value)) {
                                        isMatched = false;
                                        break;
                                    }
                                } catch (IllegalAccessException e) {
                                    throw new RuntimeException(e);
                                } catch (InvocationTargetException e) {
                                    throw new RuntimeException(e);
                                } catch (NoSuchMethodException e) {
                                    throw new RuntimeException(e);
                                }
                            }
                        }

                        if (isMatched) {
                            affectedSubscriptions.add(subscription);
                        }
                    }
                }
            }
        }

        try {
            String jsonMessage = objectMapper.writeValueAsString(message);
            for (SocketSession subscription : affectedSubscriptions) {
                WebSocketSession session = subscription.getSession();
                session.sendMessage(new TextMessage(jsonMessage));
            }
        } catch (IOException e) {
            log.warn("Cannot dispatch message", e);
        }
    }

    public SocketOutgoingMessage.DESCRIBE describe(
            WebSocketSession session,
            SocketIncomingMessage.DESCRIBE request
    ) throws SocketCommandException {

        SocketSession socketSession = bySessionId.get(session.getId());

        if (socketSession == null) {
            throw new SocketCommandException(request, String.format("Unknown session: '%s'", session.getId()));
        }

        String subscriptionId = request.getSubscriptionId();

        if (subscriptionId == null) {
            throw new SocketCommandException(request, "Property 'subscriptionId' is required");
        }

        SocketSubscription subscription = socketSession.getSubscriptions().get(subscriptionId);

        if (subscription == null) {
            throw new SocketCommandException(request, String.format("Unknown subscription: '%s'", subscriptionId));
        }

        return SocketOutgoingMessage.DESCRIBE.builder()
                .sessionId(session.getId())
                .subscriptionId(subscriptionId)
                .messageId(request.getMessageId())
                .subscription(subscription)
                .build();
    }

    public SocketOutgoingMessage.SUBSCRIBED subscribe(
            WebSocketSession session,
            SocketIncomingMessage.SUBSCRIBE request
    ) throws SocketCommandException {

        SocketSession socketSession = bySessionId.get(session.getId());

        if (socketSession == null) {
            throw new SocketCommandException(request, String.format("Unknown session: '%s'", session.getId()));
        }

        String subscriptionId = request.getSubscriptionId();

        if (subscriptionId == null) {
            throw new SocketCommandException(request, "Property 'subscriptionId' is required");
        }

        String accessToken = request.getAccessToken();

        if (accessToken == null) {
            throw new SocketCommandException(request, "Property 'accessToken' is required");
        }

        Collection<MessageSelector> selectors = request.getSelectors();

        if (selectors == null) {
            throw new SocketCommandException(request, "Property 'selectors' is required");
        }

        JwtAuthenticationToken authentication = null;
        try {
            JwtAuthenticationConverter converter = new JwtAuthenticationConverter();
            converter.setJwtGrantedAuthoritiesConverter(new JwtAuthoritiesExtractor());
            Jwt jwt = jwtDecoder.decode(accessToken);
            authentication = (JwtAuthenticationToken) converter.convert(jwt);
        } catch (Exception e) {
            throw new SocketCommandException(request, "Invalid token", e);
        }

        SocketSubscription socketSubscription = SocketSubscription
                .builder()
                .authentication(authentication)
                .subscriptionId(subscriptionId)
                .selectors(selectors)
                .build();

        socketSession.subscriptions.put(subscriptionId, socketSubscription);

        return SocketOutgoingMessage.SUBSCRIBED
                .builder()
                .sessionId(session.getId())
                .subscriptionId(subscriptionId)
                .messageId(request.getMessageId())
                .build();
    }

    public SocketOutgoingMessage.UNSUBSCRIBED unsubscribe(
            WebSocketSession session,
            SocketIncomingMessage.UNSUBSCRIBE request
    ) throws SocketCommandException {

        SocketSession socketSession = bySessionId.get(session.getId());

        if (socketSession == null) {
            throw new SocketCommandException(request, String.format("Unknown session: '%s'", session.getId()));
        }

        String subscriptionId = request.getSubscriptionId();

        if (subscriptionId == null) {
            throw new SocketCommandException(request, "Property 'subscriptionId' is required");
        }

        socketSession.subscriptions.remove(subscriptionId);

        return SocketOutgoingMessage.UNSUBSCRIBED
                .builder()
                .sessionId(session.getId())
                .subscriptionId(request.getSubscriptionId())
                .messageId(request.getMessageId())
                .build();
    }

    public SocketOutgoingMessage.LIST list(
            WebSocketSession session,
            SocketIncomingMessage.LIST request
    ) throws SocketCommandException {

        SocketSession socketSession = bySessionId.get(session.getId());

        if (socketSession == null) {
            throw new SocketCommandException(request, String.format("Unknown session: '%s'", session.getId()));
        }

        return SocketOutgoingMessage.LIST
                .builder()
                .messageId(Optional.ofNullable(request).map(SocketIncomingMessage::getMessageId).orElse(null))
                .sessionId(session.getId())
                .subscriptions(socketSession.getSubscriptions().keySet())
                .build();
    }

    public SocketOutgoingMessage.HELLO hello(
            WebSocketSession session,
            SocketIncomingMessage.HELLO request
    ) throws SocketCommandException {

        SocketSession socketSession = bySessionId.get(session.getId());

        if (socketSession == null) {
            throw new SocketCommandException(request, String.format("Unknown session: '%s'", session.getId()));
        }

        return SocketOutgoingMessage.HELLO
                .builder()
                .messageId(Optional.ofNullable(request).map(SocketIncomingMessage::getMessageId).orElse(null))
                .sessionId(session.getId())
                .message(request.getMessage())
                .build();
    }

    public void reply(WebSocketSession session, SocketOutgoingMessage response) {
        try {
            String jsonMessage = objectMapper.writeValueAsString(response);
            session.sendMessage(new TextMessage(jsonMessage));
        } catch (IOException e) {
            log.warn("Cannot reply", e);
        }
    }

    public void replyWithError(WebSocketSession session, SocketIncomingMessage command, String reason) {
        SocketOutgoingMessage.FAILURE response = SocketOutgoingMessage.FAILURE
                .builder()
                .messageId(Optional.ofNullable(command).map(SocketIncomingMessage::getMessageId).orElse(null))
                .reason(reason)
                .build();

        reply(session, response);
    }

    @Data
    @Builder
    @RequiredArgsConstructor
    public static final class SocketSession {
        private final WebSocketSession session;
        private final Map<String, SocketSubscription> subscriptions;
    }

    @Data
    @Builder
    @RequiredArgsConstructor
    public static final class SocketSubscription {
        private final String subscriptionId;
        private final JwtAuthenticationToken authentication;
        private final Collection<MessageSelector> selectors;
    }
}
