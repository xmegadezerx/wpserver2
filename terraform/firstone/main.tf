terraform {
  required_version = ">=1.0"
}

provider "aws" {
  region  = "us-east-1"
}

#creating security group with ssh and http

resource "aws_security_group" "mainsecgroup" {
         name = "mainsecgroup"

         ingress {
                 from_port = 22
                 to_port = 22
                 protocol = "tcp"
                 cidr_blocks = ["0.0.0.0/0"]
         }
         
         ingress {
                 from_port = 80
                 to_port = 80
                 protocol = "tcp"
                 cidr_blocks = ["0.0.0.0/0"]

         }

         egress {
                 from_port = 0
                 to_port = 0
                 protocol = "-1"
                 cidr_blocks = ["0.0.0.0/0"]
         }

}

#creating key-pair for logging into EC2 in us-east-1
resource "aws_key_pair" "worker-key" {
  key_name   = "id_rsa"
  public_key = file("~/.ssh/id_rsa.pub")

}

#creating aws_instance
resource "aws_instance" "app_server" {
  ami           = "ami-0e472ba40eb589f49"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.mainsecgroup.name}"]
  key_name = "id_rsa"
  tags = {
    Name = "wpserver"
  }
}

provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras install ansible2 -y",
      "sudo yum install git -y",
      "git clone git@github.com:xmegadezerx/wpserver2.git /tmp/wp",
      "ansible-playbook /tmp/wp/wpserver2/ansible/wordpress/playbook.yaml"
    ]
  }
}