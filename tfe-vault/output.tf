output "vault_server_public_ip_with_port" {
  value = "http://${aws_instance.vault_instance.public_ip}:8200"
} 

output "vault_ssh_command" {
  value = "ssh -i \"vault_ssh_key.pem\" ec2-user@${aws_instance.vault_instance.public_ip}"
}