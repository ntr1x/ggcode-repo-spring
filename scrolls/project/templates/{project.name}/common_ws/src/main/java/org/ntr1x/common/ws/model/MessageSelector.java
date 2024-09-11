package org.ntr1x.common.ws.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;
import java.util.Objects;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MessageSelector {
    private Map<String, Filter> headers;
    private Map<String, Filter> properties;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class Filter {
        private FilterType type = FilterType.EQUAL;
        private String value;

        public boolean match(String value) {
            switch (type) {
                case EQUAL: return Objects.equals(this.value, value);
                case MATCH: return value != null && value.matches(this.value);
            }
            return false;
        }
    }

    public enum FilterType {
        EQUAL,
        MATCH
    }
}
