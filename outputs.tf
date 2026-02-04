# VPC outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = alicloud_vpc.vpc.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = alicloud_vpc.vpc.cidr_block
}

# VSwitch outputs
output "vswitch_id" {
  description = "The ID of the VSwitch"
  value       = alicloud_vswitch.vswitch.id
}

# Security Group outputs
output "security_group_id" {
  description = "The ID of the security group"
  value       = alicloud_security_group.security_group.id
}

# RDS outputs
output "db_instance_id" {
  description = "The ID of the RDS instance"
  value       = alicloud_db_instance.rds_db_instance.id
}

output "db_connection_string" {
  description = "The connection string of the RDS instance"
  value       = alicloud_db_instance.rds_db_instance.connection_string
}

output "database_name" {
  description = "The name of the database"
  value       = alicloud_db_database.rds_database.data_base_name
}

# ECS outputs
output "ecs_instance_id" {
  description = "The ID of the ECS instance"
  value       = alicloud_instance.ecs_instance.id
}

output "ecs_instance_public_ip" {
  description = "The public IP address of the ECS instance"
  value       = alicloud_instance.ecs_instance.public_ip
}

output "ecs_instance_private_ip" {
  description = "The private IP address of the ECS instance"
  value       = alicloud_instance.ecs_instance.private_ip
}

# WordPress URL output
output "wordpress_url" {
  description = "The WordPress admin access URL"
  value       = "http://${alicloud_instance.ecs_instance.public_ip}/wp-admin"
}

output "wordpress_site_url" {
  description = "The WordPress site URL"
  value       = "http://${alicloud_instance.ecs_instance.public_ip}"
}

# ECS Command outputs
output "ecs_command_id" {
  description = "The ID of the ECS command"
  value       = alicloud_ecs_command.run_command.id
}

output "ecs_invocation_id" {
  description = "The ID of the ECS invocation"
  value       = alicloud_ecs_invocation.run_command.id
}