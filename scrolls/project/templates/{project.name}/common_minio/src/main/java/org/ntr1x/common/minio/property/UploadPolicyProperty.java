package org.ntr1x.common.minio.property;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.util.unit.DataSize;

import java.time.Duration;

@Data
@Builder(toBuilder = true)
@NoArgsConstructor
@AllArgsConstructor
public
class UploadPolicyProperty {
    private Duration duration;
    private String contentType;
    private DataSize dataSize;
}
