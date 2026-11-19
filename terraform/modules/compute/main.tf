# Automatically fetch the latest Ubuntu 24.04 LTS AMI in your region
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group for the 3 EC2 instances
# (Port 80 from the ALB will be attached in root main.tf to avoid a module cycle)
resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2-sg"
  description = "Allow SSH for Ansible and HTTP from ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH for Ansible"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-ec2-sg"
  }
}

# 3 EC2 Web Servers spread across the 2 public subnets
resource "aws_instance" "web" {
  count                       = var.instance_count
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_ids[count.index % length(var.public_subnet_ids)]
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-web-${count.index + 1}"
    Role = "WebServer" # Matches ansible/aws_ec2.yaml filter
  }
}