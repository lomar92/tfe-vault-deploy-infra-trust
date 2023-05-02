variable "aws_region" {
  default = "eu-central-1"
}

# Define variables
variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  default = "10.0.1.0/24"
}

variable "ssh_key_name" {
  description = "name of your pub key in aws"
}

variable "vault_version" {
  description = "specify vault version"
}

variable "vault_license" {
  description = "Vault License Key"
}

variable "private_key_path" {
  description = "path to your private key"
}

variable "aws_access_key" {
  description = "AWS Access Key ID"
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
}
