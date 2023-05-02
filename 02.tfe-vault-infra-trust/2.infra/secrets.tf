provider "vault" {}

resource "vault_mount" "example" {
  path    = "example"
  type    = "kv-v2"
  options = { version = "2" }
}

resource "vault_kv_secret_v2" "example" {
  mount = vault_mount.example.path

  name                = "unsecret"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      foo = "bar"
    }
  )
}

# Create 2nd kv mount
resource "vault_mount" "group-kv" {
  path        = "group-kv"
  type        = "kv"
  options     = { version = "2" }
  description = "This is Group-KV based on Metadata of Identity Group"
}

resource "vault_kv_secret_v2" "group-kv" {
  mount               = vault_mount.group-kv.path
  name                = "training/db_cred"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      zip = "zap",
      foo = "bar"
    }
  )
}

# 3rd Secrets Engine for User Groups based on Identity Group Name, which requires policy with Identity group id
resource "vault_kv_secret_v2" "group-kv-3" {
  mount               = vault_mount.group-kv.path
  name                = "training/${var.secrets_path}/db_cred"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      zip = "zap",
      foo = "bar"
    }
  )
}
