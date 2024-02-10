provider "aws" {
  region = "us-east-1"  
}

locals {
    aws_key = "my_aws_key_3"   # Change this to your desired AWS region
  }

resource "aws_instance" "my_server" {
   ami           = data.aws_ami.amazonlinux.id
   instance_type = var.instance_type
   key_name      = "${local.aws_key}"
  
   tags = {
     Name = "my ec2"
   }
   
   security_groups = [aws_security_group.my_sec_group.name] // security group from resource
   user_data = <<-EOF
               #!/bin/bash
                yum update -y
                dnf install php8.1 -y
                dnf install php8.1-mysqlnd.x86_64 -y
                service httpd restart
                sudo yum install -y mariadb105-server
                service mariadb start
                mysqladmin -uroot create blog
                
                systemctl start httpd
                systemctl enable httpd
                
                systemctl start mariadb
                systemctl enable mariadb
                
                mysql -e "CREATE DATABASE blog;"
                mysql -e "CREATE USER 'root'@'localhost' IDENTIFIED BY 'password';"
                mysql -e "GRANT ALL PRIVILEGES ON blog.* TO 'root'@'localhost';"
                mysql -e "FLUSH PRIVILEGES;"
                
                cd /var/www/html
                wget https://wordpress.org/latest.tar.gz
                tar -xzf latest.tar.gz
                mv wordpress blog
                cd blog
                cp wp-config-sample.php wp-config.php
                
                sed -i 's/database_name_here/blog/g' wp-config.php
                sed -i 's/username_here/root/g' wp-config.php
                sed -i 's/password_here/password/g' wp-config.php               
                
                chown -R apache:apache /var/www/html/
                
                mysql_secure_installation <<EOF
                
                
                      y
                      password
                      password
                      y
                      y
                      y
                      y
    EOF

 }


/*
Security group for EC2 instance to allow HTTP trafic
*/
resource "aws_security_group" "my_sec_group" {
  name           = "my-security-group"
  vpc_id         = "vpc-09035b347e7490cb1" // default vpc
  
  // allow http/incoming traffic
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  // allow outgoing trafficl; does WP install need this?
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}