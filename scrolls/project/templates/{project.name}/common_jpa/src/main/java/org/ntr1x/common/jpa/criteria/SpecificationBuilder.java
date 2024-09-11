package org.ntr1x.common.jpa.criteria;

import jakarta.persistence.criteria.*;

import java.math.BigDecimal;
import java.util.*;

public class SpecificationBuilder<E> {
    private final Root<E> root;
    private final CriteriaQuery<?> query;
    private final CriteriaBuilder cb;
    private final PredicateFactory<E> predicateFactory;

    private final List<Predicate> predicates = new ArrayList<>();
    private final List<Order> sorting = new ArrayList<>();

    public static <E> SpecificationBuilder<E> create(Root<E> root, CriteriaQuery<?> query, CriteriaBuilder cb) {
        return new SpecificationBuilder<>(root, query, cb);
    }

    private SpecificationBuilder(Root<E> root, CriteriaQuery<?> query, CriteriaBuilder cb) {
        this.root = root;
        this.query = query;
        this.cb = cb;

        this.predicateFactory = new PredicateFactory<>(root, query, cb);
    }

    public SpecificationBuilder<E> withOptionalMatch(String name, Optional<?> optional) {
        Predicate predicate = predicateFactory.fromOptional(name, optional);
        if (predicate != null) {
            this.predicates.add(predicate);
        }
        return this;
    }

    public SpecificationBuilder<E> withValueMatch(String name, Object value) {
        Predicate predicate = predicateFactory.fromValue(name, value);
        if (predicate != null) {
            this.predicates.add(predicate);
        }
        return this;
    }

    public <T> SpecificationBuilder<E> withOptionalPathMatch(String name, Object bean, Class<T> clazz, String path) {
        Predicate predicate = predicateFactory.fromOptionalPath(name, bean, clazz, path);
        if (predicate != null) {
            this.predicates.add(predicate);
        }
        return this;
    }

    public <T> SpecificationBuilder<E> withPredicates(Predicate... predicates) {
        this.predicates.addAll(Arrays.stream(predicates).filter(Objects::nonNull).toList());
        return this;
    }

    public <T> SpecificationBuilder<E> withWhereStatements(Collection<WhereStatement> statements) {
        if (statements == null || statements.isEmpty()) {
            return this;
        }

        Predicate[] predicates = statements
                .stream()
                .map(st -> st.buildPredicate(predicateFactory))
                .toArray(Predicate[]::new);

        this.predicates.add(predicateFactory.cb.and(predicates));

        return this;
    }

    public <T> SpecificationBuilder<E> withOrderStatements(Collection<OrderStatement> statements) {
        if (statements == null || statements.isEmpty()) {
            return this;
        }

        Collection<Order> collection = new ArrayList<>();

        for (OrderStatement statement : statements) {
            Expression<BigDecimal> criteriaExpression = statement
                    .buildExpression(BigDecimal.class, predicateFactory);
            switch (statement.direction) {
                case ASC: collection.add(cb.asc(criteriaExpression));
                case DESC: collection.add(cb.desc(criteriaExpression));
            }
        }

        this.sorting.addAll(collection);

        return this;
    }

    public Predicate build() {
        if (!sorting.isEmpty()) {
            query.orderBy(sorting);
        }
        return cb.and(predicates.toArray(Predicate[]::new));
    }
}
