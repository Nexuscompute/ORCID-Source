package org.orcid.api.config;

import javax.ws.rs.ApplicationPath;

import org.glassfish.jersey.server.ResourceConfig;
import org.glassfish.jersey.server.ServerProperties;
import org.orcid.api.common.filter.ApiVersionCheckFilter;
import org.orcid.api.filters.AnalyticsFilter;
import org.orcid.api.publicV3.server.PublicV3ApiServiceImplV3_0;
import org.springframework.context.annotation.Configuration;

@ApplicationPath("/*")
public class PublicApiResourceConfig extends ResourceConfig {
    
    public PublicApiResourceConfig() {
        System.out.println("---------------------------------------------------------------------------------");
        System.out.println("PublicApiResourceConfig");
        System.out.println("---------------------------------------------------------------------------------");
        packages("org.orcid.api.publicV3.server;org.orcid.api.publicV2.server");
        //registerClasses(ApiVersionCheckFilter.class);
        //registerClasses(AnalyticsFilter.class);
        //register(PublicV3ApiServiceImplV3_0.class);
        property(ServerProperties.WADL_FEATURE_DISABLE, true);
    }

}
