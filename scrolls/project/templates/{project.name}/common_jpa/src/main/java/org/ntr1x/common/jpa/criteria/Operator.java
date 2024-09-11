package org.ntr1x.common.jpa.criteria;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.Collection;

public interface Operator {

    @Data
    class UNARY implements Operator {
        @NotNull @Valid
        private ExpressionArgument arg;
    }

    @Data
    class BINARY implements Operator {
        @NotNull @Valid
        private ExpressionArgument a;
        @NotNull @Valid
        private ExpressionArgument b;
    }

    @Data
    class TERNARY implements Operator {
        @NotNull @Valid
        private ExpressionArgument a;
        @NotNull @Valid
        private ExpressionArgument b;
        @NotNull @Valid
        private ExpressionArgument c;
    }

    @Data
    class VARYING implements Operator {
        @NotNull
        private Collection<@Valid ExpressionArgument> args;
    }
}
