package org.ntr1x.common.security.config;

import jakarta.validation.constraints.NotNull;
import lombok.Data;
import org.ntr1x.common.security.property.OpenidClientProperty;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Data
@Configuration
@ConfigurationProperties(prefix = "app.openid")
public class OpenidConfig {
    @NotNull
    private OpenidClientProperty client;
}
