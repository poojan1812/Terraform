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
   provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd git -y",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
    ]
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
resource "null_resource" "remoteRes" {

  depends_on = [
    aws_volume_attachment.ebsConn,
  ]
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.tkey.private_key_pem
    host        = aws_instance.osConfig.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mfks.ext4 /dev/xvdh",
      "sudo mount /dev/xvdh /var/www/html",
      "sudo rm -rf /var/www/html/*",
      "sudo git clone  https://github.com/poojan1812/hybrid-cloud.git  /var/www/html/",
    ]
  }
}

resource "aws_s3_bucket" "s3-task1vol" {
  bucket = "s3-task1vol"
  acl    = "public-read"
  tags = {
    Name = "s3-task1vol"
  }
}

locals {
  s3_origin_id = "s3origin"
}

output "s3-vol" {
  value = aws_s3_bucket.s3-task1vol
}

resource "aws_cloudfront_origin_access_identity" "identity" {
  comment = "access identity"
}
output "origin_access_identity" {
  value = aws_cloudfront_origin_access_identity.identity
}


resource "aws_cloudfront_distribution" "s3Dis" {
  origin {
    domain_name = "${aws_s3_bucket.s3-task1vol.bucket_regional_domain_name}"
    origin_id   = local.s3_origin_id
    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.identity.cloudfront_access_identity_path}"
    }
  }
  enabled             = true
  is_ipv6_enabled     = true
  wait_for_deployment = false

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}


resource "aws_s3_bucket_object" "objbucket1" {
  bucket = "s3-task1vol"
  key    = "cloud.png"
}
    
## ===== Same configuration using EFS instead of EBS ===== ##
    resource "aws_efs_file_system" "efs_volume2" {
  depends_on = [aws_security_group.security_1allow,
  aws_instance.osConfig]
  creation_token = "efs_volume_tok"
  tags = {
    Name = "efsVol"
  }
}

resource "aws_efs_mount_target" "efs_myMount" {

  subnet_id      = "${aws_instance.osConfig.subnet_id}"
  file_system_id = "${aws_efs_file_system.efs_volume2.id}"

}

resource "null_resource" "remoteRes" {

  depends_on = [
    aws_efs_mount_target.efs_myMount,
  ]
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.tkey.private_key_pem
    host        = aws_instance.osConfig.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mount -t ${aws_efs_file_system.efs_volume2.id}:/ /var/www/html",
      "sudo rm -rf /var/www/html/* ",
      "sudo git clone  https://github.com/poojan1812/hybrid-cloud.git  /var/www/html/",

    ]
  }
}

    

