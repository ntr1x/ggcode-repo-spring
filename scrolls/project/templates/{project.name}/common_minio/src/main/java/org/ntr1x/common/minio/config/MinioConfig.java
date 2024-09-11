package org.ntr1x.common.minio.config;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import org.ntr1x.common.minio.property.BucketProperty;
import org.ntr1x.common.minio.property.ClientProperty;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

import java.util.ArrayList;
import java.util.Collection;

@Data
@Configuration
@ConfigurationProperties(prefix = "app.minio")
public class MinioConfig {
    @NotNull
    private ClientProperty client;

    private Collection<@Valid BucketProperty> buckets = new ArrayList<>();
}
