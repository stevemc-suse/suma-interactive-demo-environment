
resource "aws_instance" "suma" {
  count         = 1
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
      "sudo SUSEConnect -r ${var.suse_manager_subscription}",
      "sudo SUSEConnect -p sle-module-public-cloud/15.4/x86_64"
    ]

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("/Users/steve/Projects/suma-demo-rodeo/suma-demo.pem")
    }
  }
}
