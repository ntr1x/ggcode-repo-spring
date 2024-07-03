package org.ntr1x.common.ws.handler;

import lombok.extern.slf4j.Slf4j;
import org.ntr1x.common.ws.exception.SocketCommandException;
import org.ntr1x.common.ws.model.SocketIncomingMessage;
import org.ntr1x.common.ws.model.SocketOutgoingMessage;
import org.ntr1x.common.ws.service.SocketHubService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

@Slf4j
@Component
public class WebSocketHandler extends TextWebSocketHandler {

    @Autowired
    private SocketHubService socketHubService;

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        socketHubService.attach(session);
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        socketHubService.detach(session);
    }

    @Override
    public void handleTextMessage(WebSocketSession session, TextMessage textMessage) {
        try {
            SocketIncomingMessage incomingMessage = socketHubService
                    .decode(session, textMessage.getPayload());

            SocketOutgoingMessage response = null;

            if (incomingMessage instanceof SocketIncomingMessage.SUBSCRIBE request) {
                response = socketHubService.subscribe(session, request);
            } else if (incomingMessage instanceof SocketIncomingMessage.UNSUBSCRIBE request) {
                response = socketHubService.unsubscribe(session, request);
            } else if (incomingMessage instanceof SocketIncomingMessage.DESCRIBE request) {
                response = socketHubService.describe(session, request);
            } else if (incomingMessage instanceof SocketIncomingMessage.LIST request) {
                response = socketHubService.list(session, request);
            } else if (incomingMessage instanceof SocketIncomingMessage.HELLO request) {
                response = socketHubService.hello(session, request);
            }

            socketHubService.reply(session, response);
        } catch (SocketCommandException e) {
            log.warn("Cannot execute command", e);
            socketHubService.replyWithError(session, e.getCommand(), e.getMessage());
        }
    }
}