package org.ntr1x.common.minio.config;

import io.minio.MinioClient;
import org.ntr1x.common.minio.component.MinioBucketRegistry;
import org.ntr1x.common.minio.property.ClientProperty;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

@Configuration
public class MinioBeanConfig {

    @Autowired
    private MinioConfig config;

    @Bean
    @Primary
    public MinioClient client() {
        ClientProperty clientConfig = config.getClient();

        return MinioClient.builder()
                .endpoint(clientConfig.getEndpoint())
                .credentials(clientConfig.getAccessKey(), clientConfig.getSecretKey())
                .region(clientConfig.getRegion())
                .build();
    }

    @Bean
    @Primary
    public MinioBucketRegistry bucketRegistry() {
        return new MinioBucketRegistry(config.getBuckets());
    }
}
