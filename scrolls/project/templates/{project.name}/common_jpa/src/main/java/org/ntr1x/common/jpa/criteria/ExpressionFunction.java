package org.ntr1x.common.jpa.criteria;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.criteria.Expression;
import jakarta.validation.Valid;
import jakarta.validation.constraints.AssertTrue;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.Objects;
import java.util.stream.Stream;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ExpressionFunction {

    @Valid
    private Operator.TERNARY similarTo;
    @Valid
    private Operator.TERNARY regexpLike;
    @Valid
    private Operator.BINARY startsWith;
    @Valid
    private Operator.BINARY similarity;

    private Stream<Object> properties() {
        return Stream.of(
                similarTo,
                regexpLike,
                startsWith,
                similarity
        );
    }

    @JsonIgnore
    @AssertTrue(message = "One of the properties should be defined.")
    public boolean isAtLeastOneSet() {
        return properties().filter(Objects::nonNull).count() > 0;
    }

    @JsonIgnore
    @AssertTrue(message = "Properties are mutually exclusive.")
    public boolean isOnlyOneSet() {
        return properties().filter(Objects::nonNull).count() <= 1;
    }

    public <T, E> Expression<T> buildExpression(Class<T> clazz, PredicateFactory<E> context) {
        if (similarTo != null) {
            Expression<String> a = similarTo.getA().buildExpression(String.class, context);
            Expression<String> b = similarTo.getB().buildExpression(String.class, context);
            Expression<BigDecimal> c = similarTo.getC().buildExpression(BigDecimal.class, context);
            return context.cb.greaterThanOrEqualTo(
                    context.cb.function("similarity", BigDecimal.class, a, b),
                    c
            ).as(clazz);
        } else if (regexpLike != null) {
            Expression<String> a = regexpLike.getA().buildExpression(String.class, context);
            Expression<String> b = regexpLike.getB().buildExpression(String.class, context);
            Expression<String> c = regexpLike.getC().buildExpression(String.class, context);
            return c == null
                    ? context.cb.function("regexp_like", Boolean.class, a, b).as(clazz)
                    : context.cb.function("regexp_like", Boolean.class, a, b, c).as(clazz);
        } else if (startsWith != null) {
            Expression<String> a = startsWith.getA().buildExpression(String.class, context);
            Expression<String> b = startsWith.getB().buildExpression(String.class, context);
            return context.cb.function("starts_with", Boolean.class, a, b).as(clazz);
        } else if (similarity != null) {
            Expression<String> a = similarity.getA().buildExpression(String.class, context);
            Expression<String> b = similarity.getB().buildExpression(String.class, context);
            return context.cb.function("similarity", BigDecimal.class, a, b).as(clazz);
        }

        throw new IllegalStateException("Should not happen");
    }
}
