# ==============================================================================
# AWS EC2 MODULE - OUTPUTS DEFINITION
# ==============================================================================

output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.ec2.id
}

output "private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.ec2.private_ip
}

output "public_ip" {
  description = "Public IP address (if associated)"
  value       = aws_instance.ec2.public_ip
}

output "ami_id_used" {
  description = "Amazon Linux 2023 AMI ID used to launch the instance"
  value       = data.aws_ami.amazon_linux_2023.id
}

output "ebs_kms_key_arn" {
  description = "KMS CMK ARN used for EBS volume encryption"
  value       = aws_kms_key.ebs_kms.arn
}
