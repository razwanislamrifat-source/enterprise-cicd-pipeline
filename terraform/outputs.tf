# Public IP address of the Jenkins master instance.
output "jenkins_master_ip" {
  description = "Public IP address assigned to the Jenkins master instance."
  value       = aws_instance.jenkins_master.public_ip
}

# Public IP address of the Jenkins agent instance.
output "jenkins_agent_ip" {
  description = "Public IP address assigned to the Jenkins agent instance."
  value       = aws_instance.jenkins_agent.public_ip
}

# Public IP address of the Ansible controller instance.
output "ansible_controller_ip" {
  description = "Public IP address assigned to the Ansible controller instance."
  value       = aws_instance.ansible_controller.public_ip
}

# Identifier of the VPC created for the project.
output "vpc_id" {
  description = "ID of the VPC provisioned for the Advanced CI/CD environment."
  value       = aws_vpc.main.id
}
