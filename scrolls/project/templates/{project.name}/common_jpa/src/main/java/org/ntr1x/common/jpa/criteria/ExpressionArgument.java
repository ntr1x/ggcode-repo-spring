package org.ntr1x.common.jpa.criteria;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.criteria.Expression;
import jakarta.validation.Valid;
import jakarta.validation.constraints.AssertTrue;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Objects;
import java.util.Optional;
import java.util.stream.Stream;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ExpressionArgument {

    private Optional<String> value;
    private Optional<String> prop;
    @Valid
    private Optional<ExpressionFunction> func;

    private Stream<Object> properties() {
        return Stream.of(
                value,
                prop,
                func
        );
    }

    @JsonIgnore
    @AssertTrue(message = "One of the properties should be defined.")
    private boolean isAtLeastOneSet() {
        return properties().filter(Objects::nonNull).count() > 0;
    }

    @JsonIgnore
    @AssertTrue(message = "Properties are mutually exclusive.")
    private boolean isOnlyOneSet() {
        return properties().filter(Objects::nonNull).count() <= 1;
    }

    @JsonIgnore
    @AssertTrue(message = "Property 'prop' should not be defined as null")
    private boolean isPropIsNotNull() {
        return prop == null || prop.isPresent();
    }

    @JsonIgnore
    @AssertTrue(message = "Property 'func' should not be defined as null")
    private boolean isFuncIsNotNull() {
        return func == null || func.isPresent();
    }

    public <T, E> Expression<T> buildExpression(Class<T> clazz, PredicateFactory<E> context) {
        if (value != null) {
            return context.cb.literal(value.orElse(null)).as(clazz);
        } else if (prop != null) {
            // TODO @i.pavlenko: Lookup in nested objects
            return context.root.get(prop.orElseThrow()).as(clazz);
        } else if (func != null) {
            return func.orElseThrow().buildExpression(clazz, context);
        }
        throw new IllegalStateException("Should not happen");
    }
}
