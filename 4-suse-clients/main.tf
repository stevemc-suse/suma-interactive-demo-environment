#provider "aws" {
#  access_key = "<key>"
#  secret_key = "<key>"
#  region     = "eu-west-1"
#}

resource "aws_instance" "sle15sp3" {
  count         = 2
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
      #"echo '${aws_instance.suma.private_ip} suma.geekosoup.com suma salt' | sudo tee -a /etc/hosts",
      #"echo '${aws_instance.suma-monsrv.private_ip} suma-monsrv.geekosoup.com suma-monsrv' | sudo tee -a /etc/hosts",
      #  "echo '${aws_instance.suma-proxy.private_ip} suma-proxy.geekosoup.com suma-proxy' | sudo tee -a /etc/hosts"
    ]


    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("../terraform.tfstate.d/suma-demo.pem")
    }
  }
}

resource "aws_instance" "sle12sp5" {
  count         = 2
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
      #"echo '${aws_instance.suma.private_ip} suma.geekosoup.com suma salt' | sudo tee -a /etc/hosts",
      #"echo '${aws_instance.suma-monsrv.private_ip} suma-monsrv.geekosoup.com suma-monsrv' | sudo tee -a /etc/hosts",
      #  "echo '${aws_instance.suma-proxy.private_ip} suma-proxy.geekosoup.com suma-proxy' | sudo tee -a /etc/hosts"
    ]


    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("../terraform.tfstate.d/suma-demo.pem")
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
  filename = "inventory.txt"
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
  filename = "hostfile.txt"
}
