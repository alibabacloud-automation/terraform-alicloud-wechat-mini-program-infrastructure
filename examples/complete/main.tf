provider "alicloud" {
  region = var.region_id
}

# Generate a random suffix for resource names
resource "random_id" "suffix" {
  byte_length = 8
}

# Data sources for querying available zones and instance types
data "alicloud_db_zones" "rds_zones" {
  engine                   = "MySQL"
  engine_version           = "8.0"
  instance_charge_type     = "PostPaid"
  category                 = "Basic"
  db_instance_storage_type = "cloud_essd"
}

data "alicloud_instance_types" "default" {
  system_disk_category = "cloud_essd"
  image_id             = data.alicloud_images.default.images[0].id
  instance_type_family = "ecs.c6"
  availability_zone    = data.alicloud_db_zones.rds_zones.zones[length(data.alicloud_db_zones.rds_zones.zones) - 1].id
}

data "alicloud_images" "default" {
  name_regex  = "^centos_7_9_x64_20G_alibase_*"
  most_recent = true
  owners      = "system"
}

data "alicloud_db_instance_classes" "example" {
  zone_id                  = data.alicloud_db_zones.rds_zones.zones[length(data.alicloud_db_zones.rds_zones.zones) - 1].id
  engine                   = data.alicloud_db_zones.rds_zones.engine
  engine_version           = data.alicloud_db_zones.rds_zones.engine_version
  category                 = data.alicloud_db_zones.rds_zones.category
  db_instance_storage_type = data.alicloud_db_zones.rds_zones.db_instance_storage_type
  instance_charge_type     = data.alicloud_db_zones.rds_zones.instance_charge_type
}

# Call the module
module "wechat_mini_program" {
  source = "../../"

  vpc_config = {
    cidr_block = var.vpc_cidr_block
    vpc_name   = "${var.name_prefix}-vpc-${random_id.suffix.hex}"
  }

  vswitch_config = {
    cidr_block   = var.vswitch_cidr_block
    zone_id      = data.alicloud_db_zones.rds_zones.zones[length(data.alicloud_db_zones.rds_zones.zones) - 1].id
    vswitch_name = "${var.name_prefix}-vswitch-${random_id.suffix.hex}"
  }

  security_group_config = {
    security_group_name = "${var.name_prefix}-sg-${random_id.suffix.hex}"
    security_group_type = "normal"
  }

  # Note: Default allows access from any IP (0.0.0.0/0) - restrict for production
  security_group_rules = [
    {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "80/80"
      cidr_ip     = var.vswitch_cidr_block
    },
    {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "22/22"
      cidr_ip     = var.vswitch_cidr_block
    }
  ]

  db_instance_config = {
    engine                   = data.alicloud_db_instance_classes.example.engine
    engine_version           = data.alicloud_db_instance_classes.example.engine_version
    instance_type            = data.alicloud_db_instance_classes.example.instance_classes[length(data.alicloud_db_instance_classes.example.instance_classes) - 1].instance_class
    instance_storage         = 40
    db_instance_storage_type = data.alicloud_db_instance_classes.example.db_instance_storage_type
  }

  db_config = {
    db_name       = var.db_name
    character_set = "utf8mb4"
    db_user       = var.db_user
    account_type  = "Normal"
    db_password   = var.db_password
    privilege     = "ReadWrite"
  }

  ecs_config = {
    instance_name              = "${var.name_prefix}-ecs-${random_id.suffix.hex}"
    system_disk_category       = data.alicloud_instance_types.default.system_disk_category
    image_id                   = data.alicloud_images.default.images[0].id
    password                   = var.ecs_instance_password
    instance_type              = data.alicloud_instance_types.default.instance_types[0].id
    internet_max_bandwidth_out = 5
  }

  ecs_command_config = {
    name             = "${var.name_prefix}-command-${random_id.suffix.hex}"
    description      = "WordPress installation command"
    enable_parameter = false
    type             = "RunShellScript"
    timeout          = 3600
    working_dir      = "/root"
  }

  ecs_invocation_config = {
    timeout = "10m"
  }

  wordpress_config = {
    user_name  = var.wordpress_user_name
    password   = var.wordpress_password
    user_email = var.wordpress_user_email
  }
}