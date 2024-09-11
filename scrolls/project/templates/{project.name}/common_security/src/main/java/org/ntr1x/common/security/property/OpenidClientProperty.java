package org.ntr1x.common.security.property;

import jakarta.validation.constraints.NotEmpty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder(toBuilder = true)
@NoArgsConstructor
@AllArgsConstructor
public class OpenidClientProperty {
    @NotEmpty
    private String issuerUri;
    @NotEmpty
    private String clientId;
    @NotEmpty
    private String clientSecret;
    @Builder.Default
    private String tokenPath = "/protocol/openid-connect/token";
    @Builder.Default
    private String authorizationPath = "/protocol/openid-connect/auth";
    @Builder.Default
    private String userinfoPath = "/protocol/openid-connect/userinfo";
    @Builder.Default
    private String revokePath = "/protocol/openid-connect/revoke";
    @NotEmpty
    private String redirectUri;
}
