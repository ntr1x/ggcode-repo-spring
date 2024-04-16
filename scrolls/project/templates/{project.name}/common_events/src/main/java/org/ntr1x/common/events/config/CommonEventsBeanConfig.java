package org.ntr1x.common.events.config;

import org.ntr1x.common.events.annotation.EventAspect;
import org.ntr1x.common.events.service.CommonEventsRegistryService;
import org.ntr1x.common.events.service.CommonEventsSetupService;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.context.annotation.Bean;

@AutoConfiguration
public class CommonEventsBeanConfig {
    @Bean
    public EventAspect eventAspect() {
        return new EventAspect();
    }

    @Bean
    public CommonEventsSetupService commonEventsSetupService() {
        return new CommonEventsSetupService();
    }

    @Bean
    public CommonEventsRegistryService commonEventsRegistryService() {
        return new CommonEventsRegistryService();
    }
}
