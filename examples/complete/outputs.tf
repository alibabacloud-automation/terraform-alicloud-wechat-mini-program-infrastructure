output "wordpress_url" {
  description = "The WordPress admin access URL"
  value       = module.wechat_mini_program.wordpress_url
}

output "wordpress_site_url" {
  description = "The WordPress site URL"
  value       = module.wechat_mini_program.wordpress_site_url
}

output "ecs_instance_public_ip" {
  description = "The public IP address of the ECS instance"
  value       = module.wechat_mini_program.ecs_instance_public_ip
}

output "db_connection_string" {
  description = "The connection string of the RDS instance"
  value       = module.wechat_mini_program.db_connection_string
  sensitive   = true
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.wechat_mini_program.vpc_id
}

output "vswitch_id" {
  description = "The ID of the VSwitch"
  value       = module.wechat_mini_program.vswitch_id
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = module.wechat_mini_program.security_group_id
}

output "ecs_instance_id" {
  description = "The ID of the ECS instance"
  value       = module.wechat_mini_program.ecs_instance_id
}

output "db_instance_id" {
  description = "The ID of the RDS instance"
  value       = module.wechat_mini_program.db_instance_id
}