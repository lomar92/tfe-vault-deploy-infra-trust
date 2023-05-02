resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

resource "vault_generic_endpoint" "u1" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/u1"
  ignore_absent_fields = true

  data_json = <<EOT
{

  "password": "password"
}
EOT
}

resource "vault_generic_endpoint" "u2" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/u2"
  ignore_absent_fields = true

  data_json = <<EOT
{

  "password": "password"
}
EOT
}

resource "vault_identity_entity" "u1_entity" {
  depends_on = [vault_generic_endpoint.u1]
  name       = "u1"
}

resource "vault_identity_entity" "u2_entity" {
  depends_on = [vault_generic_endpoint.u2]
  name       = "u2"
}

resource "vault_identity_entity_alias" "u1_alias" {
  depends_on     = [vault_identity_entity.u1_entity]
  name           = "u1"
  mount_accessor = vault_auth_backend.userpass.accessor
  canonical_id   = vault_identity_entity.u1_entity.id
}

resource "vault_identity_entity_alias" "u2_alias" {
  depends_on     = [vault_identity_entity.u2_entity]
  name           = "u2"
  mount_accessor = vault_auth_backend.userpass.accessor
  canonical_id   = vault_identity_entity.u2_entity.id
}

resource "vault_identity_group" "group" {
  name = "development"

  # policies = [vault_policy.group-policy.name]
  policies = ["group-policy"]

  member_entity_ids = [
    vault_identity_entity.u1_entity.id,
    vault_identity_entity.u2_entity.id
  ]

  metadata = {
    region = "berlin"
  }
}