package org.ntr1x.common.ws.config;

import org.ntr1x.common.ws.handler.WebSocketHandler;
import org.ntr1x.common.ws.service.SocketHubService;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class WebSocketHubConfig {
    @Bean
    public SocketHubService socketHubService() {
        return new SocketHubService();
    }

    @Bean
    public WebSocketHandler webSocketHandler() {
        return new WebSocketHandler();
    }
}
