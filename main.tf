# Define provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.32.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region  = "us-east-2"
  profile = "ovia-terraform"
}

# Create an alias for us-east-1 (N.Virginia)
provider "aws" {
  alias   = "us"
  region  = "us-east-1"
  profile = "ovia-terraform"
}


# Define input variables
variable "instance_type" {
  type        = string
  description = "The instance capacity"
  sensitive   = false
  default     = "t2.micro"

}

# Create an EC2 instance
resource "aws_instance" "ovia-app" {
  ami           = "ami-07b36ea9852e986ad"
  instance_type = var.instance_type

  tags = {
    Name = "ovia-instance"
  }
}

# Create a VPC

module "vpc" {
  providers = {
    aws = aws.us
  }
  source = "terraform-aws-modules/vpc/aws"

  name = "ovia-vpc"
  cidr = "10.0.0.0/16"

  #azs             = ["us-east-2a", "us-east-2b", "us-east-2c"]
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# Get outputs
output "public_ip" {
  description = "The public IP of the instance"
  value       = aws_instance.ovia-app.public_ip
  sensitive   = false
}