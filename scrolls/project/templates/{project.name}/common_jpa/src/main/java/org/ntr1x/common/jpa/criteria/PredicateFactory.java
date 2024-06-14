package org.ntr1x.common.jpa.criteria;

import jakarta.persistence.criteria.*;
import lombok.RequiredArgsConstructor;
import org.apache.commons.beanutils.PropertyUtilsBean;

import java.lang.reflect.InvocationTargetException;
import java.util.Optional;

@RequiredArgsConstructor
public class PredicateFactory<T> {
    private final Root<T> root;
    private final CriteriaQuery<T> query;
    private final CriteriaBuilder cb;

    public Predicate fromOptionalPath(String name, Object bean, Class<T> clazz, String path) {
        return fromOptional(name, findInOptionalPath(bean, clazz, path));
    }

    public Predicate fromOptional(String name, Optional<?> optional) {
        if (optional == null) {
            return null;
        }
        Path<T> cursor = root;
        String[] segments = name.split("\\.");
        for (String segment : segments) {
            cursor = cursor.get(segment);
        }

        Path<T> element = cursor;

        return optional
                .map(value -> cb.equal(element, value))
                .orElse(cb.isNull(element));
    }

    public Predicate fromValue(String name, Object value) {
        return fromOptional(name, Optional.ofNullable(value));
    }

    private static <T> Optional<T> findInOptionalPath(Object bean, Class<T> clazz, String path) {
        String[] segments = path.split("\\.");

        PropertyUtilsBean pub = new PropertyUtilsBean();

        try {
            Object cursor = bean;
            for (int i = 0; i < segments.length; i++) {
                String segment = segments[i];
                Object next = pub.getProperty(cursor, segment);
                if (next == null) {
                    return null;
                } else if (next instanceof Optional<?> optional) {
                    cursor = optional.orElse(null);
                } else {
                    cursor = next;
                }
            }
            if (cursor == null) {
                return Optional.empty();
            } else if (clazz.isInstance(cursor)) {
                return Optional.of(clazz.cast(cursor));
            }
            throw new IllegalStateException(String.format("Invalid path: %s", path));
        } catch (InvocationTargetException e) {
            throw new RuntimeException(e);
        } catch (IllegalAccessException e) {
            throw new RuntimeException(e);
        } catch (NoSuchMethodException e) {
            throw new RuntimeException(e);
        }
    }
}
