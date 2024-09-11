package org.ntr1x.common.ws.exception;

import lombok.Getter;
import org.ntr1x.common.ws.model.SocketIncomingMessage;
import org.springframework.web.socket.WebSocketSession;

public class SocketCommandException extends Exception {

    @Getter
    private final SocketIncomingMessage command;

    public SocketCommandException(SocketIncomingMessage command, String message, Throwable cause) {
        super(message, cause);
        this.command = command;
    }

    public SocketCommandException(SocketIncomingMessage command, String message) {
        this(command, message, null);
    }
}
