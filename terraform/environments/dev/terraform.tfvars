# ==============================================================================
# TERRAFORM DEV ENVIRONMENT VARIABLES VALUES
# ==============================================================================

environment               = "dev"
aws_region                = "us-east-1"
azure_location            = "eastus"
azure_resource_group      = "rg-multicloud-dev-01"
vpc_cidr                  = "10.0.0.0/16"
azure_vnet_cidr           = "10.1.0.0/16"
bastion_ssh_allowed_cidrs = ["0.0.0.0/0"]
