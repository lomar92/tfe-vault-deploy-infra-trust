# Create VPC
resource "aws_vpc" "vault_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "vault vpc"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "vault_igw" {
  vpc_id = aws_vpc.vault_vpc.id
  tags = {
    Name = "vault internet gateway"
  }
}

# Create route table Vault
resource "aws_route_table" "vault_rt" {
  vpc_id = aws_vpc.vault_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vault_igw.id
  }
  tags = {
    Name = "Vault public rtb"
  }
}

# Create subnet
resource "aws_subnet" "vault_subnet" {
  vpc_id     = aws_vpc.vault_vpc.id
  cidr_block = var.subnet_cidr_block
  tags = {
    Name = "vault subnet"
  }
}

# Associate subnet with route table
resource "aws_route_table_association" "vault_rta" {
  subnet_id      = aws_subnet.vault_subnet.id
  route_table_id = aws_route_table.vault_rt.id
}

# Create security group for Vault
resource "aws_security_group" "vault_sg" {
  name_prefix = "vault_ontap_sg"
  vpc_id      = aws_vpc.vault_vpc.id
  ## SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ## HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ## HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ## Vault Port
  ingress {
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ## Ping ICMP
  ingress {
    description = "Allow ping"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ## Egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
