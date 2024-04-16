package org.ntr1x.common.events.contributor;

import org.ntr1x.common.events.model.CloudEventRoute;

import java.util.Map;

public interface CommonEventsRouteContributor {
    void addRoutes(Map<String, CloudEventRoute> routes);
}
