package org.ntr1x.common.api.annotation;

import java.lang.annotation.*;

@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Repeatable(Events.class)
public @interface Event {
    String route() default "";

    String type() default "";

    String payloadEl() default "#result";

    String topic() default "";

    /**
     * URI of the event source
     *
     * @return URI in string representation
     */
    String source() default "";
}
