{
  group_id = "org.example",
  artifact_id = "example",
  parent = {
    group_id = "org.springframework.boot",
    artifact_id = "spring-boot-starter-parent",
    version = "3.2.5",
  },
  modules = {
    "common_api",
    "common_web",
  },
  properties = {
    ["flatten-maven-plugin.version"] = "1.5.0",
    ["logstash.logback.version"] = "7.3",
    ["cloudevents.version"] = "3.0.0",
    ["commons-text.version"] = "1.12.0",
    ["commons-beanutils.version"] = "1.9.4",
    ["hypersistence.version"] = "3.7.4",
    ["vavr.version"] = "0.10.4",
    ["minio.version"] = "8.5.11"
  },
  dependency_management = {
    dependencies = {
      { group_id = "com.zaxxer", artifact_id = "HikariCP", version = "5.0.1" },
      { group_id = "org.projectlombok", artifact_id = "lombok", version = "1.18.30" },
      { group_id = "org.springdoc", artifact_id = "springdoc-openapi-common", version = "1.6.9" },
      { group_id = "io.swagger.core.v3", artifact_id = "swagger-annotations", version = "2.2.20" },
      { group_id = "org.springdoc", artifact_id = "springdoc-openapi-starter-webmvc-api", version = "2.3.0" },
      { group_id = "com.mysql", artifact_id = "mysql-connector-j", version = "8.3.0" },
      { group_id = "org.postgresql", artifact_id = "postgresql", version = "42.3.3" },
      { group_id = "io.minio", artifact_id = "minio", version = "${minio.version}" },
      { group_id = "io.vavr", artifact_id = "vavr", version = "${vavr.version}" },
      { group_id = "net.logstash.logback", artifact_id = "logstash-logback-encoder", version = "${logstash.logback.version}" },
      { group_id = "io.cloudevents", artifact_id = "cloudevents-spring", version = "${cloudevents.version}" },
      { group_id = "io.cloudevents", artifact_id = "cloudevents-kafka", version = "${cloudevents.version}" },
      { group_id = "io.cloudevents", artifact_id = "cloudevents-json-jackson", version = "${cloudevents.version}" },
      { group_id = "org.apache.commons", artifact_id = "commons-text", version = "${commons-text.version}" },
      { group_id = "commons-beanutils", artifact_id = "commons-beanutils", version = "${commons-beanutils.version}" },
      { group_id = "io.hypersistence", artifact_id = "hypersistence-utils-hibernate-63", version = "${hypersistence.version}" },
    }
  },
}
