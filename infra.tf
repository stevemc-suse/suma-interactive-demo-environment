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
  #key_name_prefix = "${var.prefix}-"
  key_name = "suma-demo"
  public_key = tls_private_key.global_key.public_key_openssh
}

resource "local_file" "private_key_file" {
  filename = "./terraform.tfstate.d/suma-demo.pem"
  content  = tls_private_key.global_key.private_key_pem
  file_permission = "0400"
}

resource "aws_instance" "suma" {
  #count         = 1
  ami           = "ami-0365f8f06cbc8bf57"  # Replace with the correct SUSE Manager  AMI ID
  instance_type = "t3.xlarge"  # Replace with the desired instance type
  key_name      = "suma-demo"  # Replace with the name of your keypair

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = 64
  } 
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = 512
    volume_type = "gp2"
    delete_on_termination = true

  }
  tags = {
    Name = "suma"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname suma", 
      "echo '${aws_instance.suma.private_ip} suma.geekosoup.com suma salt' | sudo tee -a /etc/hosts",
      "sudo SUSEConnect -r ${var.suse_manager_subscription}",
      "sudo SUSEConnect -p sle-module-public-cloud/15.4/x86_64"
    ]

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${tls_private_key.global_key.private_key_pem}"
    }
  }
}


resource "aws_instance" "suma-proxy" {
  ami           = "ami-00cb22bc2742d27d9"  # Replace with the correct SLE15SP3 AMI ID
  instance_type = "t2.large"  # Replace with the desired instance type
  key_name      = "suma-demo"  # Replace with the name of your keypair
  security_groups = ["suma-clients"]
  depends_on = [aws_instance.suma]

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = 128
    volume_type = "gp2"
    delete_on_termination = true

  }

  tags = {
    Name = "suma-proxy"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${self.tags.Name}",
      "echo '${aws_instance.suma.private_ip} suma.geekosoup.com suma salt' | sudo tee -a /etc/hosts"
  #    "echo '${aws_instance.suma-monsrv.private_ip} suma-monsrv.geekosoup.com suma-monsrv' | sudo tee -a /etc/hosts",
  #    "echo '${aws_instance.suma-proxy.private_ip} suma-proxy.geekosoup.com suma-proxy' | sudo tee -a /etc/hosts"
    ]
  }

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${tls_private_key.global_key.private_key_pem}"
    }
  }

resource "aws_instance" "suma-monsrv" {
  ami           = "ami-09ee771fad415a6d7"  # Replace with the correct SLE12SP5 AMI ID
  instance_type = "t2.micro"  # Replace with the desired instance type
  key_name      = "suma-demo"  # Replace with the name of your keypair
  security_groups = ["suma-clients"]
  depends_on = [aws_instance.suma-proxy]

  tags = {
    Name = "suma-monsrv"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${self.tags.Name}",
      "echo '${aws_instance.suma.private_ip} suma.geekosoup.com suma salt' | sudo tee -a /etc/hosts"
 #     "echo '${aws_instance.suma-monsrv.private_ip} suma-monsrv.geekosoup.com suma-monsrv' | sudo tee -a /etc/hosts",
 #     "echo '${aws_instance.suma-proxy.private_ip} suma-proxy.geekosoup.com suma-proxy' | sudo tee -a /etc/hosts"
    ]

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${tls_private_key.global_key.private_key_pem}"
    }
  }
}

resource "aws_instance" "sle15sp3" {
  count         = 1
  ami           = "ami-0a6802b4742e7fdf6"  # Replace with the correct SLE15SP3 AMI ID
  instance_type = "t2.micro"  # Replace with the desired instance type
  key_name      = "suma-demo"  # Replace with the name of your keypair
  security_groups = ["suma-clients"]

  tags = {
    Name = "${count.index + 1}-sle15-server"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${self.tags.Name}",
      "echo '${aws_instance.suma.private_ip} suma.geekosoup.com suma salt' | sudo tee -a /etc/hosts",
      "echo '${aws_instance.suma-monsrv.private_ip} suma-monsrv.geekosoup.com suma-monsrv' | sudo tee -a /etc/hosts",
      "echo '${aws_instance.suma-proxy.private_ip} suma-proxy.geekosoup.com suma-proxy' | sudo tee -a /etc/hosts"
    ]


    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${tls_private_key.global_key.private_key_pem}"
    }
  }
}

resource "aws_instance" "sle12sp5" {
  count         = 1
  ami           = "ami-00cece0cb7d8e8ee4"  # Replace with the correct SLE12SP5 AMI ID
  instance_type = "t2.micro"  # Replace with the desired instance type
  key_name      = "suma-demo"  # Replace with the name of your keypair
  security_groups = ["suma-clients"]

  tags = {
    Name = "${count.index + 1}-sle12-server"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${self.tags.Name}",
      "echo '${aws_instance.suma.private_ip} suma.geekosoup.com suma salt' | sudo tee -a /etc/hosts",
      "echo '${aws_instance.suma-monsrv.private_ip} suma-monsrv.geekosoup.com suma-monsrv' | sudo tee -a /etc/hosts",
      "echo '${aws_instance.suma-proxy.private_ip} suma-proxy.geekosoup.com suma-proxy' | sudo tee -a /etc/hosts"
    ]


    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ec2-user"
      private_key = "${tls_private_key.global_key.private_key_pem}"
    }
  }
}

# Generate the inventory file for the use with ansible
locals {
  inventory_content = <<INVENTORY
[sle15sp3]
${join("\n", [for instance in aws_instance.sle15sp3 : "${instance.public_ip}"])} 

[sle12sp5]
${join("\n", [for instance in aws_instance.sle12sp5 : "${instance.public_ip}"])}
INVENTORY
}

# Write the inventory file locally
resource "local_file" "inventory" {
  content  = local.inventory_content
  filename = "./terraform.tfstate.d/inventory.txt"
}

# Generate the inventory hostfile this will need to be coppied to SUSE Manager  
locals {
  inventory_content_hostfile = <<INVENTORY
${join("\n", [for instance in aws_instance.sle15sp3 : "${instance.private_ip} ${instance.tags.Name}"])}

${join("\n", [for instance in aws_instance.sle12sp5 : "${instance.private_ip} ${instance.tags.Name}"])}
INVENTORY
}

# Write the inventory file locally
resource "local_file" "hostfile" {
  content  = local.inventory_content_hostfile
  filename = "./terraform.tfstate.d/hostfile.txt"
}
