package org.ntr1x.common.jpa.criteria;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.criteria.Expression;
import jakarta.persistence.criteria.Predicate;
import jakarta.validation.Valid;
import jakarta.validation.constraints.AssertTrue;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;
import java.util.Objects;
import java.util.stream.Stream;

@Data
public class WhereStatement {

    @JsonProperty("$or")
    private List<@Valid WhereStatement> __or;

    @JsonProperty("$and")
    private List<@Valid WhereStatement> __and;

    @Valid
    @JsonProperty("$not")
    private Operator.UNARY __not;

    @Valid
    @JsonProperty("$gt")
    private Operator.BINARY __gt;

    @Valid
    @JsonProperty("$gte")
    private Operator.BINARY __gte;

    @Valid
    @JsonProperty("$lt")
    private Operator.BINARY __lt;

    @Valid
    @JsonProperty("$lte")
    private Operator.BINARY __lte;

    @Valid
    @JsonProperty("$eq")
    private Operator.BINARY __eq;

    @Valid
    @JsonProperty("$neq")
    private Operator.BINARY __neq;

    @Valid
    @JsonProperty("$like")
    private Operator.BINARY __like;

    @Valid
    @JsonProperty("$between")
    private Operator.TERNARY __between;

    @Valid
    @JsonProperty("$similar")
    private Operator.TERNARY __similar;

    private Stream<Object> properties() {
        return Stream.of(
                __not, __or, __and, __gt, __gte, __lt, __lte, __eq, __neq, __like, __between, __similar
        );
    }

    @AssertTrue(message = "One of the properties should be defined.")
    public boolean isAtLeastOneSet() {
        return properties().filter(Objects::nonNull).count() > 0;
    }

    @AssertTrue(message = "Properties are mutually exclusive.")
    public boolean isOnlyOneSet() {
        return properties().filter(Objects::nonNull).count() <= 1;
    }

    public <E> Predicate buildPredicate(PredicateFactory<E> context) {
        if (__not != null) {
            ExpressionArgument arg = __not.getArg();
            return context.cb.not(arg.buildExpression(Boolean.class, context));
        } else if (__or != null) {
            Predicate[] predicates = __or
                    .stream()
                    .map(arg -> context.cb.not(arg.buildPredicate(context)))
                    .toArray(Predicate[]::new);
            return context.cb.or(predicates);
        } else if (__and != null) {
            Predicate[] predicates = __and
                    .stream()
                    .map(arg -> context.cb.not(arg.buildPredicate(context)))
                    .toArray(Predicate[]::new);
            return context.cb.and(predicates);
        } else if (__gt != null) {
            Expression<BigDecimal> a = __gt.getA().buildExpression(BigDecimal.class, context);
            Expression<BigDecimal> b = __gt.getB().buildExpression(BigDecimal.class, context);
            return context.cb.greaterThan(a, b);
        } else if (__gte != null) {
            Expression<BigDecimal> a = __gte.getA().buildExpression(BigDecimal.class, context);
            Expression<BigDecimal> b = __gte.getB().buildExpression(BigDecimal.class, context);
            return context.cb.greaterThanOrEqualTo(a, b);
        } else if (__lt != null) {
            Expression<BigDecimal> a = __lt.getA().buildExpression(BigDecimal.class, context);
            Expression<BigDecimal> b = __lt.getB().buildExpression(BigDecimal.class, context);
            return context.cb.lessThan(a, b);
        } else if (__lte != null) {
            Expression<BigDecimal> a = __lte.getA().buildExpression(BigDecimal.class, context);
            Expression<BigDecimal> b = __lte.getB().buildExpression(BigDecimal.class, context);
            return context.cb.lessThanOrEqualTo(a, b);
        } else if (__eq != null) {
            Expression<BigDecimal> a = __eq.getA().buildExpression(BigDecimal.class, context);
            Expression<BigDecimal> b = __eq.getB().buildExpression(BigDecimal.class, context);
            return context.cb.equal(a, b);
        } else if (__neq != null) {
            Expression<BigDecimal> a = __neq.getA().buildExpression(BigDecimal.class, context);
            Expression<BigDecimal> b = __neq.getB().buildExpression(BigDecimal.class, context);
            return context.cb.notEqual(a, b);
        } else if (__like != null) {
            Expression<String> a = __like.getA().buildExpression(String.class, context);
            Expression<String> b = __like.getB().buildExpression(String.class, context);
            return context.cb.like(a, b);
        } else if (__between != null) {
            Expression<BigDecimal> a = __between.getA().buildExpression(BigDecimal.class, context);
            Expression<BigDecimal> b = __between.getB().buildExpression(BigDecimal.class, context);
            Expression<BigDecimal> c = __between.getC().buildExpression(BigDecimal.class, context);
            return context.cb.between(a, b, c);
        } else if (__similar != null) {
            Expression<String> a = __similar.getA().buildExpression(String.class, context);
            Expression<String> b = __similar.getB().buildExpression(String.class, context);
            Expression<BigDecimal> c = __similar.getC().buildExpression(BigDecimal.class, context);
            return context.cb.greaterThanOrEqualTo(
                    context.cb.function("similarity", BigDecimal.class, a, b),
                    c
            );
        }

        throw new IllegalStateException("Should not happen");
    }
}
