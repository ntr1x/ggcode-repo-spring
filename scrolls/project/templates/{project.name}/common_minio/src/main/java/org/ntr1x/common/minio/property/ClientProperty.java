package org.ntr1x.common.minio.property;

import jakarta.validation.constraints.NotEmpty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder(toBuilder = true)
@NoArgsConstructor
@AllArgsConstructor
public class ClientProperty {
    @NotEmpty
    private String endpoint;
    @NotEmpty
    private String accessKey;
    @NotEmpty
    private String secretKey;
    private String region;
}
