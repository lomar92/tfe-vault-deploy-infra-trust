# Define AWS provider
provider "aws" {
  region = "eu-central-1"
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

# Create Vault Server
resource "aws_instance" "vault_instance" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t2.micro"
  key_name                    = var.ssh_key_name
  subnet_id                   = aws_subnet.vault_subnet.id
  vpc_security_group_ids      = [aws_security_group.vault_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.vault_instance_profile.name

  tags = {
    Name = "vault-instance"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.private_key_path)
    host        = aws_instance.vault_instance.public_ip
  }

  provisioner "file" {
    source      = "ansible/install_vault.yml"
    destination = "/home/ec2-user/install_vault.yml"
  }
}

resource "null_resource" "install_ansible" {
  depends_on = [aws_instance.vault_instance]

  triggers = {
    always_run = timestamp()
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.private_key_path)
    host        = aws_instance.vault_instance.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y amazon-linux-extras",
      "sudo amazon-linux-extras install -y ansible2",
      "pip3 install ansible",
    ]
  }
}

resource "null_resource" "install_vault" {
  depends_on = [null_resource.install_ansible]

  triggers = {
    always_run = timestamp()
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.private_key_path)
    host        = aws_instance.vault_instance.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "amazon-linux-extras install -y ansible2",
      "pip3 install ansible",
      "echo export VAULT_LICENSE=${var.vault_license} >> ~/.bashrc",
      "echo export VAULT_ADDR='http://0.0.0.0:8200' >> ~/.bashrc",
      "source /home/ec2-user/.bashrc",
      "chmod u+x /home/ec2-user/install_vault.yml",
      "sleep 2",
      "ansible-playbook /home/ec2-user/install_vault.yml"
    ]
  }
}