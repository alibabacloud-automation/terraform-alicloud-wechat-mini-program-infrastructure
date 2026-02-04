variable "region_id" {
  type        = string
  description = "The region ID where to create resources"
  default     = "cn-hangzhou"
}

variable "name_prefix" {
  type        = string
  description = "The prefix for resource names"
  default     = "wechat-mini-program"
}

variable "vpc_cidr_block" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "192.168.0.0/16"
}

variable "vswitch_cidr_block" {
  type        = string
  description = "The CIDR block for the VSwitch"
  default     = "192.168.0.0/24"
}

variable "db_name" {
  type        = string
  description = "The name of the database"
  default     = "wordpress"
}

variable "db_user" {
  type        = string
  description = "The database user name"
  default     = "dbuser"
}

variable "db_password" {
  type        = string
  description = "The database password"
  sensitive   = true
  default     = "password"
}

variable "ecs_instance_password" {
  type        = string
  description = "The password for the ECS instance"
  sensitive   = true
  default     = "password"
}

variable "wordpress_user_name" {
  type        = string
  description = "The WordPress administrator username"
  default     = "admin"
}

variable "wordpress_password" {
  type        = string
  description = "The WordPress administrator password"
  sensitive   = true
  default     = "password"
}

variable "wordpress_user_email" {
  type        = string
  description = "The WordPress administrator email"
  default     = "admin@example.com"
}
