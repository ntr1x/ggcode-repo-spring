package org.ntr1x.common.minio.property;

import jakarta.validation.constraints.NotEmpty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Duration;

@Data
@Builder(toBuilder = true)
@NoArgsConstructor
@AllArgsConstructor
public class BucketProperty {

    @NotEmpty
    private String name;

    @Builder.Default
    private UploadPolicyProperty uploadPolicy = UploadPolicyProperty
            .builder()
            .duration(Duration.ofSeconds(300))
            .build();

    @Builder.Default
    private DownloadPolicyProperty downloadPolicy = DownloadPolicyProperty
            .builder()
            .duration(Duration.ofSeconds(300))
            .build();
}
