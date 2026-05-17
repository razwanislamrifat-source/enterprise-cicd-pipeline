# Centralized AMI selection for the EC2 fleet in this stack.
locals {
  amazon_linux_2_ami = "ami-0c02fb55956c7d316"
}

# Jenkins master instance that hosts the CI/CD controller.
resource "aws_instance" "jenkins_master" {
  ami                         = local.amazon_linux_2_ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[0].id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.jenkins_master.id]
  associate_public_ip_address = true
  monitoring                  = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
    encrypted   = true
  }

  volume_tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-master-root"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-master"
    role = "jenkins_master"
  }
}

# Jenkins agent instance used for distributed build and deployment workloads.
resource "aws_instance" "jenkins_agent" {
  ami                         = local.amazon_linux_2_ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[0].id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.jenkins_agent.id]
  associate_public_ip_address = true
  monitoring                  = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  volume_tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-agent-root"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-agent"
    role = "jenkins_agent"
  }
}

# Ansible controller instance used to manage remote configuration tasks.
resource "aws_instance" "ansible_controller" {
  ami                         = local.amazon_linux_2_ami
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.public[0].id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.ansible_controller.id]
  associate_public_ip_address = true
  monitoring                  = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 16
    encrypted   = true
  }

  volume_tags = {
    Name = "${var.project_name}-${var.environment}-ansible-controller-root"
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-ansible-controller"
    role = "ansible_controller"
  }
}
