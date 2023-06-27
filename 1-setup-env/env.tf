#resource "aws_key_pair" "suma-demo" {
#  key_name   = "suma-demo"  # Replace with your desired key pair name
#  public_key = file("~/.ssh/id_rsa.pub")  # Replace with the path to your public key file
#}

#resource "local_file" "private_key_file" {
#  filename = "../terraform.tfstate.d/suma-demo.pem"  # Replace with the desired path to store the private key file
#  content  = aws_key_pair.suma-demo.key_pair_id
#}

# AWS infrastructure resources

resource "tls_private_key" "global_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_sensitive_file" "ssh_private_key_pem" {
  filename        = "${path.module}/id_rsa"
  content         = tls_private_key.global_key.private_key_pem
  file_permission = "0600"
}

resource "local_file" "ssh_public_key_openssh" {
  filename = "${path.module}/id_rsa.pub"
  content  = tls_private_key.global_key.public_key_openssh
}

# Temporary key pair used for SSH accesss
resource "aws_key_pair" "suma-demo_key_pair" {
  key_name_prefix = "${var.prefix}-"
  public_key      = tls_private_key.global_key.public_key_openssh
}

resource "local_file" "private_key_file" {
  filename = "./suma-demo.pem"
  content  = tls_private_key.global_key.public_key_openssh
}