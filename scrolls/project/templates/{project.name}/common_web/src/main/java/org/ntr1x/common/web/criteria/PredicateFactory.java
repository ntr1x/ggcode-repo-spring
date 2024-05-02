package org.ntr1x.common.web.criteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import lombok.RequiredArgsConstructor;

import java.util.Optional;

@RequiredArgsConstructor
public class PredicateFactory<T> {
    private final Root<T> root;
    private final CriteriaQuery<T> query;
    private final CriteriaBuilder cb;

    public Predicate fromOptional(String name, Optional<?> optional) {
        if (optional == null) {
            return null;
        }
        return optional
                .map(value -> cb.equal(root.get(name), value))
                .orElse(cb.isNull(root.get(name)));
    }

    public Predicate fromValue(String name, Object value) {
        return fromOptional(name, Optional.ofNullable(value));
    }
}
