package org.ntr1x.common.web.config;

import org.ntr1x.common.api.component.AppConverter;
import org.ntr1x.common.web.component.AppArgumentResolver;
import org.ntr1x.common.web.component.AppExceptionHandler;
import org.ntr1x.common.web.serializer.JsonPageSerializer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.jackson.Jackson2ObjectMapperBuilderCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;
import org.springframework.data.domain.Page;
import org.springframework.format.FormatterRegistry;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.util.List;

@Configuration
@Import(AppExceptionHandler.class)
public class WebMvcConfig implements WebMvcConfigurer {
    @Autowired(required = false)
    private List<AppConverter<?, ?>> converters;

    @Autowired(required = false)
    private List<AppArgumentResolver> argumentResolvers;

    @Bean
    public Jackson2ObjectMapperBuilderCustomizer jsonCustomizer() {
        return builder -> builder
                .defaultViewInclusion(true)
                .failOnUnknownProperties(false)
                .serializerByType(Page.class, new JsonPageSerializer());
    }

    @Override
    public void addFormatters(FormatterRegistry registry) {
        if (converters != null) {
            for (AppConverter converter : converters) {
                registry.addConverter(converter);
            }
        }
    }

    @Override
    public void addArgumentResolvers(List<HandlerMethodArgumentResolver> resolvers) {
        if (argumentResolvers != null) {
            for (AppArgumentResolver resolver : argumentResolvers) {
                resolvers.add(resolver);
            }
        }
    }
}
