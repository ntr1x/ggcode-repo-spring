package org.ntr1x.common.jpa.criteria;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Root;
import lombok.Builder;

@Builder(toBuilder = true)
public class SpecificationContext<T> {
    public final Root<T> root;
    public final CriteriaQuery<?> query;
    public final CriteriaBuilder cb;
}
