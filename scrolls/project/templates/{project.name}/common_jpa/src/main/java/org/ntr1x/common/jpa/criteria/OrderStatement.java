package org.ntr1x.common.jpa.criteria;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.criteria.Expression;
import jakarta.validation.Valid;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.domain.Sort;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class OrderStatement {

    @NotNull
    public Sort.Direction direction = Sort.Direction.ASC;

    public String prop;
    @Valid
    public ExpressionFunction func;

    @JsonIgnore
    @AssertTrue(message = "Either property 'prop' or property 'func' should be defined.")
    public boolean isAtLeastOneSet() {
        return prop != null || func != null;
    }

    @JsonIgnore
    @AssertTrue(message = "Properties 'prop' and 'func' are mutually exclusive.")
    public boolean isOnlyOneSet() {
        return prop == null || func == null;
    }

    public <T, E> Expression<T> buildExpression(Class<T> clazz, PredicateFactory<E> context) {
        if (prop != null) {
            return context.root.get(prop);
        } else if (func != null) {
            return func.buildExpression(clazz, context);
        }

        throw new IllegalStateException("Should not happen");
    }
}
