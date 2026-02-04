locals {

  # WordPress installation script
  ecs_command = <<SHELL
#!/bin/bash
cat << INNER_EOF >> ~/.bash_profile
export DB_NAME=${var.db_config.db_name}
export DB_USERNAME=${var.db_config.db_user}
export DB_PASSWORD=${var.db_config.db_password}
export DB_CONNECTION=${alicloud_db_instance.rds_db_instance.connection_string}
export ROS_DEPLOY=true
INNER_EOF

source ~/.bash_profile

curl -fsSL https://static-aliyun-doc.oss-cn-hangzhou.aliyuncs.com/install-script/develop-your-wechat-mini-program-in-10-minutes/install.sh|bash

## Adjust database connection configuration
sed -i 's/localhost/${alicloud_db_instance.rds_db_instance.connection_string}/' /var/www/html/wp-config.php
sed -i 's/username_here/${var.db_config.db_user}/' /var/www/html/wp-config.php
sed -i 's/password_here/${var.db_config.db_password}/' /var/www/html/wp-config.php
sed -i 's/database_name_here/${var.db_config.db_name}/' /var/www/html/wp-config.php

cd /var/www/html
sudo cat << INNER_EOF > .htaccess
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteCond \%\{HTTP:Authorization\} ^(.*)
RewriteRule ^(.*) - [E=HTTP_AUTHORIZATION:%1]
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond \%\{REQUEST_FILENAME\} !-f
RewriteCond \%\{REQUEST_FILENAME\} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
INNER_EOF
sed -i 's/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf

wget https://downloads.wordpress.org/plugin/jwt-authentication-for-wp-rest-api.zip
yum -y install unzip
unzip jwt-authentication-for-wp-rest-api.zip -d jwt-authentication-for-wp-rest-api
cp -r ./jwt-authentication-for-wp-rest-api/jwt-authentication-for-wp-rest-api /var/www/html/wp-content/plugins
rm -rf jwt-authentication-for-wp-rest-api.zip
rm -rf jwt-authentication-for-wp-rest-api
wget https://gitee.com/qin-yangming/open-tools/raw/master/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

SECRET_KEY=$(openssl rand -base64 32) && sed -i "/Database settings/i define('JWT_AUTH_SECRET_KEY', '$SECRET_KEY');\\ndefine('JWT_AUTH_CORS_ENABLE', true);\\n" /var/www/html/wp-config.php
sed -i 's/\r$//' /var/www/html/wp-config.php
wp core install --url=${alicloud_instance.ecs_instance.public_ip} --title="Hello World" --admin_user=${var.wordpress_config.user_name} --admin_password=${var.wordpress_config.password} --admin_email=${var.wordpress_config.user_email} --skip-email --allow-root

wp plugin activate jwt-authentication-for-wp-rest-api --allow-root --path=/var/www/html

systemctl restart httpd
SHELL
}

# VPC
resource "alicloud_vpc" "vpc" {
  vpc_name   = var.vpc_config.vpc_name
  cidr_block = var.vpc_config.cidr_block
}

# VSwitch
resource "alicloud_vswitch" "vswitch" {
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = var.vswitch_config.cidr_block
  zone_id      = var.vswitch_config.zone_id
  vswitch_name = var.vswitch_config.vswitch_name
}

# Security Group
resource "alicloud_security_group" "security_group" {
  vpc_id              = alicloud_vpc.vpc.id
  security_group_name = var.security_group_config.security_group_name
  security_group_type = var.security_group_config.security_group_type
}

# Security Group Rules
resource "alicloud_security_group_rule" "security_group_rules" {
  for_each = {
    for i, rule in var.security_group_rules : "${rule.type}_${i}" => rule
  }
  type              = each.value.type
  ip_protocol       = each.value.ip_protocol
  port_range        = each.value.port_range
  cidr_ip           = each.value.cidr_ip
  security_group_id = alicloud_security_group.security_group.id
}

# RDS Instance
resource "alicloud_db_instance" "rds_db_instance" {
  engine                   = var.db_instance_config.engine
  engine_version           = var.db_instance_config.engine_version
  instance_type            = var.db_instance_config.instance_type
  instance_storage         = var.db_instance_config.instance_storage
  db_instance_storage_type = var.db_instance_config.db_instance_storage_type
  vswitch_id               = alicloud_vswitch.vswitch.id
  zone_id                  = var.vswitch_config.zone_id
  security_group_ids       = [alicloud_security_group.security_group.id]
}

# RDS Database
resource "alicloud_db_database" "rds_database" {
  instance_id    = alicloud_db_instance.rds_db_instance.id
  data_base_name = var.db_config.db_name
  character_set  = var.db_config.character_set
}

# RDS Account
resource "alicloud_db_account" "rds_account" {
  db_instance_id   = alicloud_db_instance.rds_db_instance.id
  account_name     = var.db_config.db_user
  account_type     = var.db_config.account_type
  account_password = var.db_config.db_password
}

# RDS Account Privilege
resource "alicloud_db_account_privilege" "rds_account_privilege" {
  instance_id  = alicloud_db_instance.rds_db_instance.id
  account_name = alicloud_db_account.rds_account.account_name
  db_names     = [alicloud_db_database.rds_database.data_base_name]
  privilege    = var.db_config.privilege
}

# ECS Instance
resource "alicloud_instance" "ecs_instance" {
  instance_name              = var.ecs_config.instance_name
  system_disk_category       = var.ecs_config.system_disk_category
  image_id                   = var.ecs_config.image_id
  vswitch_id                 = alicloud_vswitch.vswitch.id
  password                   = var.ecs_config.password
  instance_type              = var.ecs_config.instance_type
  internet_max_bandwidth_out = var.ecs_config.internet_max_bandwidth_out
  security_groups            = [alicloud_security_group.security_group.id]
}

# ECS Command
resource "alicloud_ecs_command" "run_command" {
  name             = var.ecs_command_config.name
  description      = var.ecs_command_config.description
  enable_parameter = var.ecs_command_config.enable_parameter
  type             = var.ecs_command_config.type
  command_content  = base64encode(var.custom_install_script != null ? var.custom_install_script : local.ecs_command)
  timeout          = var.ecs_command_config.timeout
  working_dir      = var.ecs_command_config.working_dir
}

# ECS Invocation
resource "alicloud_ecs_invocation" "run_command" {
  instance_id = [alicloud_instance.ecs_instance.id]
  command_id  = alicloud_ecs_command.run_command.id

  timeouts {
    create = var.ecs_invocation_config.timeout
  }
}