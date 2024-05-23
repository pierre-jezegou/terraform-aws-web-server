region        = "us-east-1"
vpc_name      = "vpc-lab" # First, add a `Name` tag to the vpc
image_ami     = "ami-080e1f13689e07408"  # Replace with actual Ubuntu 22.04 AMI ID
key_name      = "ssh-keypair"
subnet_id     = "subnet-06c658f7c84c2145f"
subnets       = ["subnet-06c658f7c84c2145f", "subnet-0bbcc7fd3a9e1874c", "subnet-0395c004b86737c16", "subnet-0a341e4dccb8c7feb", "subnet-028a6c72942ef368a", "subnet-0d2a551970c973176"]