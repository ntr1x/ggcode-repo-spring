{
  artifact_id = "service_uploads",
  parent = {
    group_id = "org.example",
    artifact_id = "api",
  },
  dependencies = {
    { group_id = "org.postgresql", artifact_id = "postgresql", version = "42.3.3" },
  }
}
