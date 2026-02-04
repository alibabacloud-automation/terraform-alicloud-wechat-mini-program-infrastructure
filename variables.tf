
variable "vpc_config" {
  type = object({
    cidr_block = string
    vpc_name   = optional(string, null)
  })
  description = "The parameters of VPC. The attribute 'cidr_block' is required."
  default = {
    cidr_block = "192.168.0.0/16"
    vpc_name   = null
  }
}

variable "vswitch_config" {
  type = object({
    cidr_block   = string
    zone_id      = string
    vswitch_name = optional(string, null)
  })
  description = "The parameters of VSwitch. The attributes 'cidr_block' and 'zone_id' are required."
  default = {
    cidr_block   = "192.168.0.0/24"
    zone_id      = null
    vswitch_name = null
  }

  validation {
    condition     = can(cidrhost(var.vswitch_config.cidr_block, 0))
    error_message = "The vswitch_config.cidr_block must be a valid CIDR block."
  }
}

variable "security_group_config" {
  type = object({
    security_group_name = optional(string, null)
    security_group_type = optional(string, "normal")
  })
  description = "The parameters of security group."
  default = {
    security_group_name = null
    security_group_type = "normal"
  }
}

variable "security_group_rules" {
  type = list(object({
    type        = string
    ip_protocol = string
    port_range  = string
    cidr_ip     = string
  }))
  description = "The security group rules configuration as a list of objects."
  default = [
    {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "80/80"
      cidr_ip     = "0.0.0.0/0"
    },
    {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "22/22"
      cidr_ip     = "0.0.0.0/0"
    }
  ]
}


variable "db_instance_config" {
  type = object({
    engine                   = string
    engine_version           = string
    instance_type            = string
    instance_storage         = number
    db_instance_storage_type = string
  })
  description = "The parameters of RDS instance. All attributes are required."
  default = {
    engine                   = "MySQL"
    engine_version           = "8.0"
    instance_type            = null
    instance_storage         = null
    db_instance_storage_type = "cloud_essd"
  }
}

variable "db_config" {
  type = object({
    db_name       = string
    character_set = string
    db_user       = string
    account_type  = string
    db_password   = string
    privilege     = string
  })
  description = "The database configuration including name, user, password and privilege settings."
  default = {
    db_name       = "wordpress"
    character_set = "utf8mb4"
    db_user       = "dbuser"
    account_type  = "Normal"
    db_password   = null
    privilege     = "ReadWrite"
  }
  sensitive = true
}

variable "ecs_config" {
  type = object({
    instance_name              = optional(string, null)
    system_disk_category       = string
    image_id                   = string
    password                   = string
    instance_type              = string
    internet_max_bandwidth_out = number
  })
  description = "The parameters of ECS instance. The attributes 'system_disk_category', 'image_id', 'password', 'instance_type' and 'internet_max_bandwidth_out' are required."
  default = {
    instance_name              = null
    system_disk_category       = "cloud_efficiency"
    image_id                   = null
    password                   = null
    instance_type              = null
    internet_max_bandwidth_out = 5
  }
  sensitive = true
}

variable "custom_install_script" {
  type        = string
  description = "Custom installation script to run on ECS instance. If not provided, the default WordPress installation script will be used."
  default     = null
}

variable "ecs_command_config" {
  type = object({
    name             = optional(string, null)
    description      = string
    enable_parameter = bool
    type             = string
    timeout          = number
    working_dir      = string
  })
  description = "The parameters of ECS command configuration."
  default = {
    name             = null
    description      = "WordPress installation command"
    enable_parameter = false
    type             = "RunShellScript"
    timeout          = 3600
    working_dir      = "/root"
  }
}

variable "ecs_invocation_config" {
  type = object({
    timeout = string
  })
  description = "The parameters of ECS invocation configuration."
  default = {
    timeout = "10m"
  }
}

variable "wordpress_config" {
  type = object({
    user_name  = string
    password   = string
    user_email = string
  })
  description = "The WordPress administrator configuration including username, password and email."
  default = {
    user_name  = "admin"
    password   = null
    user_email = "admin@example.com"
  }
  sensitive = true
}