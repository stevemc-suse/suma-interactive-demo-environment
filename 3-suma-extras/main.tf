#provider "aws" {
#  access_key = "<key>"
#  secret_key = "<key>"
#  region     = "eu-west-1"
#}


resource "aws_instance" "suma-proxy" {
  ami           = "ami-00cb22bc2742d27d9"  # Replace with the correct SLE15SP3 AMI ID
  instance_type = "t2.large"  # Replace with the desired instance type
  key_name      = "suma-demo"  # Replace with the name of your keypair
  security_groups = ["suma-clients"]
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
      "echo '172.31.20.209 suma.geekosoup.com suma salt' | sudo tee -a /etc/hosts",
      "echo '${aws_instance.suma-monsrv.private_ip} suma-monsrv.geekosoup.com suma-monsrv' | sudo tee -a /etc/hosts"
    ]
  }

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("./suma-demo.pem")
    }
  }

resource "aws_instance" "suma-monsrv" {
  ami           = "ami-09ee771fad415a6d7"  # Replace with the correct SLE12SP5 AMI ID
  instance_type = "t2.micro"  # Replace with the desired instance type
  key_name      = "suma-demo"  # Replace with the name of your keypair
  security_groups = ["suma-clients"]

  tags = {
    Name = "suma-monsrv"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${self.tags.Name}",
      "echo '172.31.20.209 suma.geekosoup.com suma salt' | sudo tee -a /etc/hosts"
    ]


    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("../terraform.tfstate.d/suma-demo.pem")
    }
  }
}
