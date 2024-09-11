package org.ntr1x.common.minio.component;

import org.ntr1x.common.minio.property.BucketProperty;
import org.springframework.stereotype.Component;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Component
public class MinioBucketRegistry {
    private final Map<String, BucketProperty> buckets;

    public MinioBucketRegistry(Collection<BucketProperty> collection) {
        Map<String, BucketProperty> map = new HashMap<>();
        if (collection != null) {
            for (BucketProperty bucket : collection) {
                map.put(bucket.getName(), bucket);
            }
        }
        buckets = map;
    }

    public Optional<BucketProperty> bucket(String name) {
        return Optional.ofNullable(buckets.get(name));
    }
}
