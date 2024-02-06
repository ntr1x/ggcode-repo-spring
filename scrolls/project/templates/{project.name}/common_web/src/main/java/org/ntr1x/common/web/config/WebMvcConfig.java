package org.ntr1x.common.web.config;

import org.ntr1x.common.api.component.AppConverter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.format.FormatterRegistry;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.util.List;

@Configuration
@EnableWebMvc
public class WebMvcConfig implements WebMvcConfigurer {
    @Autowired
    private List<AppConverter<?, ?>> converters;

    @Override
    public void addFormatters(FormatterRegistry registry) {
        for (AppConverter converter : converters) {
            registry.addConverter(converter);
        }
    }
}
