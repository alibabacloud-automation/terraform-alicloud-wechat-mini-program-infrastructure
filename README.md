Alicloud WeChat Mini Program Infrastructure Terraform Module

# terraform-alicloud-wechat-mini-program-infrastructure

English | [简体中文](https://github.com/alibabacloud-automation/terraform-alicloud-wechat-mini-program-infrastructure/blob/main/README-CN.md)

Terraform module which creates a complete infrastructure for WeChat and Alipay mini program development on Alibaba Cloud. This module sets up a WordPress environment with all necessary components including VPC, ECS, RDS MySQL database, and automated WordPress installation.


## Usage

This module creates a complete infrastructure stack for developing WeChat and Alipay mini programs with WordPress backend. The module automatically sets up the entire environment including network infrastructure, compute resources, database, and WordPress installation.

```terraform
provider "alicloud" {
  region = "cn-hangzhou"
}

data "alicloud_db_zones" "rds_zones" {
  engine                   = "MySQL"
  engine_version           = "8.0"
  instance_charge_type     = "PostPaid"
  category                 = "Basic"
  db_instance_storage_type = "cloud_essd"
}

data "alicloud_instance_types" "default" {
  system_disk_category = "cloud_essd"
  instance_type_family = "ecs.c6"
  availability_zone    = data.alicloud_db_zones.rds_zones.zones[0].id
}

data "alicloud_images" "default" {
  name_regex  = "^centos_7_9_x64_20G_alibase_*"
  most_recent = true
  owners      = "system"
}

data "alicloud_db_instance_classes" "example" {
  zone_id                  = data.alicloud_db_zones.rds_zones.zones[0].id
  engine                   = "MySQL"
  engine_version           = "8.0"
  category                 = "Basic"
  db_instance_storage_type = "cloud_essd"
  instance_charge_type     = "PostPaid"
}

module "wechat_mini_program" {
  source = "alibabacloud-automation/wechat-mini-program-infrastructure/alicloud"

  vpc_config = {
    cidr_block = "192.168.0.0/16"
    vpc_name   = "my-mini-program-vpc"
  }

  vswitch_config = {
    cidr_block   = "192.168.0.0/24"
    zone_id      = data.alicloud_db_zones.rds_zones.zones[0].id
    vswitch_name = "my-mini-program-vswitch"
  }

  security_group_config = {
    security_group_name = "my-mini-program-sg"
    security_group_type = "normal"
  }

  db_instance_config = {
    engine                   = "MySQL"
    engine_version           = "8.0"
    instance_type            = data.alicloud_db_instance_classes.example.instance_classes[0].instance_class
    instance_storage         = data.alicloud_db_instance_classes.example.instance_classes[0].storage_range.min
    db_instance_storage_type = "cloud_essd"
  }

  db_config = {
    db_name       = "wordpress"
    character_set = "utf8mb4"
    db_user       = "dbuser"
    account_type  = "Normal"
    db_password   = "YourSecurePassword123!"
    privilege     = "ReadWrite"
  }

  ecs_config = {
    instance_name              = "my-mini-program-ecs"
    system_disk_category       = "cloud_efficiency"
    image_id                   = data.alicloud_images.default.images[0].id
    password                   = "YourECSPassword123!"
    instance_type              = data.alicloud_instance_types.default.instance_types[0].id
    internet_max_bandwidth_out = 5
  }

  ecs_command_config = {
    name             = "my-mini-program-command"
    description      = "WordPress installation command"
    enable_parameter = false
    type             = "RunShellScript"
    timeout          = 3600
    working_dir      = "/root"
  }

  wordpress_config = {
    user_name  = "admin"
    password   = "YourWordPressPassword123!"
    user_email = "admin@example.com"
  }
}
```

## Examples

* [Complete Example](https://github.com/alibabacloud-automation/terraform-alicloud-wechat-mini-program-infrastructure/tree/main/examples/complete)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_alicloud"></a> [alicloud](#requirement\_alicloud) | >= 1.212.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_alicloud"></a> [alicloud](#provider\_alicloud) | >= 1.212.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [alicloud_db_account.rds_account](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/db_account) | resource |
| [alicloud_db_account_privilege.rds_account_privilege](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/db_account_privilege) | resource |
| [alicloud_db_database.rds_database](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/db_database) | resource |
| [alicloud_db_instance.rds_db_instance](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/db_instance) | resource |
| [alicloud_ecs_command.run_command](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ecs_command) | resource |
| [alicloud_ecs_invocation.run_command](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ecs_invocation) | resource |
| [alicloud_instance.ecs_instance](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/instance) | resource |
| [alicloud_security_group.security_group](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group) | resource |
| [alicloud_security_group_rule.security_group_rules](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group_rule) | resource |
| [alicloud_vpc.vpc](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vpc) | resource |
| [alicloud_vswitch.vswitch](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vswitch) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_install_script"></a> [custom\_install\_script](#input\_custom\_install\_script) | Custom installation script to run on ECS instance. If not provided, the default WordPress installation script will be used. | `string` | `null` | no |
| <a name="input_db_config"></a> [db\_config](#input\_db\_config) | The database configuration including name, user, password and privilege settings. | <pre>object({<br/>    db_name       = string<br/>    character_set = string<br/>    db_user       = string<br/>    account_type  = string<br/>    db_password   = string<br/>    privilege     = string<br/>  })</pre> | <pre>{<br/>  "account_type": "Normal",<br/>  "character_set": "utf8mb4",<br/>  "db_name": "wordpress",<br/>  "db_password": null,<br/>  "db_user": "dbuser",<br/>  "privilege": "ReadWrite"<br/>}</pre> | no |
| <a name="input_db_instance_config"></a> [db\_instance\_config](#input\_db\_instance\_config) | The parameters of RDS instance. All attributes are required. | <pre>object({<br/>    engine                   = string<br/>    engine_version           = string<br/>    instance_type            = string<br/>    instance_storage         = number<br/>    db_instance_storage_type = string<br/>  })</pre> | <pre>{<br/>  "db_instance_storage_type": "cloud_essd",<br/>  "engine": "MySQL",<br/>  "engine_version": "8.0",<br/>  "instance_storage": null,<br/>  "instance_type": null<br/>}</pre> | no |
| <a name="input_ecs_command_config"></a> [ecs\_command\_config](#input\_ecs\_command\_config) | The parameters of ECS command configuration. | <pre>object({<br/>    name             = optional(string, "wordpress-install")<br/>    description      = string<br/>    enable_parameter = bool<br/>    type             = string<br/>    timeout          = number<br/>    working_dir      = string<br/>  })</pre> | <pre>{<br/>  "description": "WordPress installation command",<br/>  "enable_parameter": false,<br/>  "name": "wordpress-install",<br/>  "timeout": 3600,<br/>  "type": "RunShellScript",<br/>  "working_dir": "/root"<br/>}</pre> | no |
| <a name="input_ecs_config"></a> [ecs\_config](#input\_ecs\_config) | The parameters of ECS instance. The attributes 'system\_disk\_category', 'image\_id', 'password', 'instance\_type' and 'internet\_max\_bandwidth\_out' are required. | <pre>object({<br/>    instance_name              = optional(string, null)<br/>    system_disk_category       = string<br/>    image_id                   = string<br/>    password                   = string<br/>    instance_type              = string<br/>    internet_max_bandwidth_out = number<br/>  })</pre> | <pre>{<br/>  "image_id": null,<br/>  "instance_name": null,<br/>  "instance_type": null,<br/>  "internet_max_bandwidth_out": 5,<br/>  "password": null,<br/>  "system_disk_category": "cloud_efficiency"<br/>}</pre> | no |
| <a name="input_ecs_invocation_config"></a> [ecs\_invocation\_config](#input\_ecs\_invocation\_config) | The parameters of ECS invocation configuration. | <pre>object({<br/>    timeout = string<br/>  })</pre> | <pre>{<br/>  "timeout": "10m"<br/>}</pre> | no |
| <a name="input_security_group_config"></a> [security\_group\_config](#input\_security\_group\_config) | The parameters of security group. | <pre>object({<br/>    security_group_name = optional(string, null)<br/>    security_group_type = optional(string, "normal")<br/>  })</pre> | n/a | yes |
| <a name="input_security_group_rules"></a> [security\_group\_rules](#input\_security\_group\_rules) | The security group rules configuration as a list of objects. | <pre>list(object({<br/>    type        = string<br/>    ip_protocol = string<br/>    port_range  = string<br/>    cidr_ip     = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "cidr_ip": "0.0.0.0/0",<br/>    "ip_protocol": "tcp",<br/>    "port_range": "80/80",<br/>    "type": "ingress"<br/>  },<br/>  {<br/>    "cidr_ip": "0.0.0.0/0",<br/>    "ip_protocol": "tcp",<br/>    "port_range": "22/22",<br/>    "type": "ingress"<br/>  }<br/>]</pre> | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | The parameters of VPC. The attribute 'cidr\_block' is required. | <pre>object({<br/>    cidr_block = string<br/>    vpc_name   = optional(string, null)<br/>  })</pre> | n/a | yes |
| <a name="input_vswitch_config"></a> [vswitch\_config](#input\_vswitch\_config) | The parameters of VSwitch. The attributes 'cidr\_block' and 'zone\_id' are required. | <pre>object({<br/>    cidr_block   = string<br/>    zone_id      = string<br/>    vswitch_name = optional(string, null)<br/>  })</pre> | n/a | yes |
| <a name="input_wordpress_config"></a> [wordpress\_config](#input\_wordpress\_config) | The WordPress administrator configuration including username, password and email. | <pre>object({<br/>    user_name  = string<br/>    password   = string<br/>    user_email = string<br/>  })</pre> | <pre>{<br/>  "password": null,<br/>  "user_email": "admin@example.com",<br/>  "user_name": "admin"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_name"></a> [database\_name](#output\_database\_name) | The name of the database |
| <a name="output_db_connection_string"></a> [db\_connection\_string](#output\_db\_connection\_string) | The connection string of the RDS instance |
| <a name="output_db_instance_id"></a> [db\_instance\_id](#output\_db\_instance\_id) | The ID of the RDS instance |
| <a name="output_ecs_command_id"></a> [ecs\_command\_id](#output\_ecs\_command\_id) | The ID of the ECS command |
| <a name="output_ecs_instance_id"></a> [ecs\_instance\_id](#output\_ecs\_instance\_id) | The ID of the ECS instance |
| <a name="output_ecs_instance_private_ip"></a> [ecs\_instance\_private\_ip](#output\_ecs\_instance\_private\_ip) | The private IP address of the ECS instance |
| <a name="output_ecs_instance_public_ip"></a> [ecs\_instance\_public\_ip](#output\_ecs\_instance\_public\_ip) | The public IP address of the ECS instance |
| <a name="output_ecs_invocation_id"></a> [ecs\_invocation\_id](#output\_ecs\_invocation\_id) | The ID of the ECS invocation |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block of the VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
| <a name="output_vswitch_id"></a> [vswitch\_id](#output\_vswitch\_id) | The ID of the VSwitch |
| <a name="output_wordpress_site_url"></a> [wordpress\_site\_url](#output\_wordpress\_site\_url) | The WordPress site URL |
| <a name="output_wordpress_url"></a> [wordpress\_url](#output\_wordpress\_url) | The WordPress admin access URL |
<!-- END_TF_DOCS -->

## Submit Issues

If you have any problems when using this module, please opening
a [provider issue](https://github.com/aliyun/terraform-provider-alicloud/issues/new) and let us know.

**Note:** There does not recommend opening an issue on this repo.

## Authors

Created and maintained by Alibaba Cloud Terraform Team(terraform@alibabacloud.com).

## License

MIT Licensed. See LICENSE for full details.

## Reference

* [Terraform-Provider-Alicloud Github](https://github.com/aliyun/terraform-provider-alicloud)
* [Terraform-Provider-Alicloud Release](https://releases.hashicorp.com/terraform-provider-alicloud/)
* [Terraform-Provider-Alicloud Docs](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs)