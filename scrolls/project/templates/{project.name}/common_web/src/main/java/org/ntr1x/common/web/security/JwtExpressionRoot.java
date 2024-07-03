package org.ntr1x.common.web.security;

import org.springframework.security.access.expression.DenyAllPermissionEvaluator;
import org.springframework.security.access.expression.SecurityExpressionRoot;
import org.springframework.security.access.hierarchicalroles.NullRoleHierarchy;
import org.springframework.security.authentication.AuthenticationTrustResolverImpl;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtClaimAccessor;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;

import java.util.Map;

public class JwtExpressionRoot extends SecurityExpressionRoot implements JwtClaimAccessor {
    private final Jwt jwt;

    public JwtExpressionRoot(JwtAuthenticationToken authentication) {
        super(authentication);
        this.jwt = authentication.getToken();
        setTrustResolver(new AuthenticationTrustResolverImpl());
        setRoleHierarchy(new NullRoleHierarchy());
        setPermissionEvaluator(new DenyAllPermissionEvaluator());
        setDefaultRolePrefix("role:");
    }

    public String getSubject() {
        return this.jwt.getSubject();
    }

    @Override
    public Map<String, Object> getClaims() {
        return jwt.getClaims();
    }
}