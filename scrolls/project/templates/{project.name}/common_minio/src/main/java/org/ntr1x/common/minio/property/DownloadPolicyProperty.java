package org.ntr1x.common.minio.property;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Duration;

@Data
@Builder(toBuilder = true)
@NoArgsConstructor
@AllArgsConstructor
public
class DownloadPolicyProperty {
    private Duration duration;
}
