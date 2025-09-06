# These two parameters are fetched from SSM Parameter Store.
# - "mysql_sg_id" refers to the Security Group ID created in the securitygroup module.
# - "database_subnet_group_name" refers to the RDS Subnet Group, which includes subnets
#   created across two Availability Zones using the vpc/subnetgroup module. 
#   These subnets are grouped to support high availability for the RDS instance.
# Grouping subnets into a subnet group is mandatory for RDS and helps ensure fault tolerance, high availability, and easy management.

data "aws_ssm_parameter" "mysql_sg_id" {
  name = "/${var.project_name}/${var.environment}/mysql_sg_id"
}

data "aws_ssm_parameter" "database_subnet_group_name" {
  name = "/${var.project_name}/${var.environment}/database_subnet_group_name"
} 