resource "aws_iam_role" "vault_role" {
  name = "vault-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "vault_instance_profile" {
  name = "vault-profile"
  role = aws_iam_role.vault_role.name
}

resource "aws_iam_role_policy" "vault_policy" {
  name = "vault-policy"
  role = aws_iam_role.vault_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:DescribeKey"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:kms:eu-central-1:020954271809:key/5b800a14-6598-496d-af58-a0e3554c2aa9"
      }
    ]
  })
}
