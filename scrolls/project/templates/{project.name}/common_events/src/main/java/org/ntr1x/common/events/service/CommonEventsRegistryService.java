package org.ntr1x.common.events.service;

import org.ntr1x.common.events.contributor.CommonEventsContainerContributor;
import org.ntr1x.common.events.contributor.CommonEventsRouteContributor;
import org.ntr1x.common.events.model.CloudEventRoute;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.listener.MessageListenerContainer;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class CommonEventsRegistryService implements InitializingBean {
    @Autowired(required = false)
    private List<CommonEventsContainerContributor> containerContributors;
    @Autowired(required = false)
    private List<CommonEventsRouteContributor> routeContributors;

    private Map<String, CloudEventRoute> routes;
    private Map<String, MessageListenerContainer> containers;

    @Override
    public void afterPropertiesSet() {
        Map<String, CloudEventRoute> routes = new LinkedHashMap<>();
        if (routeContributors != null) {
            for (CommonEventsRouteContributor routeContributor : routeContributors) {
                routeContributor.addRoutes(routes);
            }
        }

        this.routes = routes;

        Map<String, MessageListenerContainer> containers = new LinkedHashMap<>();
        if (containerContributors != null) {
            for (CommonEventsContainerContributor containerContributor : containerContributors) {
                containerContributor.addContainers(containers);
            }
        }

        this.containers = containers;
    }

    public CloudEventRoute getRoute(String name) {
        return routes.get(name);
    }

    public MessageListenerContainer getContainer(String name) {
        return containers.get(name);
    }
}
