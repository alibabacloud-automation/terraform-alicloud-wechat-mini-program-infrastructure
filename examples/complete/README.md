# Complete Example

This example demonstrates how to use the WeChat Mini Program Infrastructure module to deploy a complete WordPress environment on Alibaba Cloud.

## What This Example Creates

This example creates the following resources:

- **VPC**: A Virtual Private Cloud with configurable CIDR block
- **VSwitch**: A subnet within the VPC for resource placement
- **Security Group**: Network security rules allowing HTTP and SSH access
- **RDS MySQL Instance**: A managed MySQL database for WordPress
- **ECS Instance**: A CentOS server running WordPress and required services
- **Database Setup**: Automatic database and user creation with proper privileges
- **WordPress Installation**: Automated WordPress installation and configuration

## Prerequisites

- Terraform >= 1.0
- Alibaba Cloud account with appropriate permissions
- Alibaba Cloud CLI configured (optional but recommended)

## Usage

1. Clone this repository or copy the example files
2. Navigate to the example directory:
   ```bash
   cd examples/complete
   ```

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Create a `terraform.tfvars` file with your configuration:
   ```hcl
   region_id              = "cn-hangzhou"
   name_prefix            = "my-wordpress"
   vpc_cidr_block         = "192.168.0.0/16"
   vswitch_cidr_block     = "192.168.0.0/24"
   db_password            = "YourSecurePassword123!"
   ecs_instance_password  = "YourECSPassword123!"
   wordpress_password     = "YourWordPressPassword123!"
   wordpress_user_email   = "your-email@example.com"
   ```

5. Plan the deployment:
   ```bash
   terraform plan
   ```

6. Apply the configuration:
   ```bash
   terraform apply
   ```

7. After deployment, access your WordPress site using the output URLs.

## Important Notes

- **Passwords**: All password variables are marked as sensitive. Make sure to use strong passwords and store them securely.
- **Network Access**: The security group allows HTTP (port 80) and SSH (port 22) access from any IP (0.0.0.0/0). Consider restricting this to your specific IP ranges for production use.
- **Resource Naming**: Resources are automatically named with a random suffix to avoid conflicts.
- **Region**: Make sure to choose a region that supports all the required services.

## Accessing WordPress

After successful deployment:

1. **WordPress Admin**: Access the WordPress admin panel using the `wordpress_url` output
2. **Website**: View the public website using the `wordpress_site_url` output
3. **SSH Access**: Connect to the ECS instance using the public IP and the configured password

## Customization

You can customize this example by:

- Modifying the VPC and subnet CIDR blocks
- Changing the database configuration
- Adjusting the ECS instance specifications
- Adding additional security group rules
- Configuring different WordPress settings

## Clean Up

To destroy the created resources:

```bash
terraform destroy
```

## Troubleshooting

- If deployment fails, check the Alibaba Cloud console for detailed error messages
- Ensure your account has sufficient permissions and quotas
- Verify that the selected region supports all required services
- Check that your CIDR blocks don't conflict with existing networks