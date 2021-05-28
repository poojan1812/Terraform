provider "aws" {

  region  = "ap-south-1" //(asian pecific 1 region)
  profile = "User_Profile"
}
resource "aws_default_vpc" "vpcmain" {
  tags = {
    Name = "Default vpc"
  }
}
## ===== Key creation ===== ##
resource "tls_private_key" "tkey" {
  algorithm = "RSA"
}

resource "aws_key_pair" "task1" {
  key_name   = "task1"
  public_key = tls_private_key.tkey.public_key_openssh
  depends_on = [tls_private_key.tkey]


}

resource "local_file" "lf" {
  content  = tls_private_key.tkey.private_key_pem
  filename = "key_name.pem"
}
## ===== Security Group ===== ##
resource "aws_security_group" "security_allow" {
  name   = "security_allow"
  vpc_id = aws_default_vpc.vpcmain.id

  ingress {
    from_port   = 80
    to_port     = 80 //ingress traffic rule for webserver running at port 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp" //ingress traffic rule for ssh running at port 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "security_allow"
  }

}

resource "aws_instance" "osConfig" {
  ami             = "ami-id"
  instance_type   = "t2.micro"
  key_name        = "key_name"
  security_groups = ["security_allow"]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.tkey.private_key_pem
    host        = aws_instance.osConfig.public_ip
  }

  tags = {
    Name = "osInstance"
  }

}

resource "aws_ebs_volume" "ebsVol" {
  availability_zone = aws_instance.osConfig.availability_zone
  size              = 1
  tags = {
    Name = "EbsVol"
  }
}

resource "aws_volume_attachment" "ebsConn" {
  device_name  = "/dev/sdh"
  volume_id    = "${aws_ebs_volume.ebsVol.id}"
  instance_id  = "${aws_instance.osConfig.id}"
  force_detach = true

}

