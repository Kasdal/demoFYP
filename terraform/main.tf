provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  config_path = "${path.module}/kubeconfig.yaml"
}

locals {
  cluster_name = "myapp-cluster"
}

resource "aws_vpc" "myapp_vpc" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name        = "myapp-vpc"
    Environment = var.env_prefix
  }
}

resource "aws_subnet" "myapp_subnet_1" {
  vpc_id                  = aws_vpc.myapp_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "<first_availability_zone>"
  map_public_ip_on_launch = true

  tags = {
    Name = "myapp-subnet-1"
  }
}

resource "aws_subnet" "myapp_subnet_2" {
  vpc_id                  = aws_vpc.myapp_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "<second_availability_zone>"
  map_public_ip_on_launch = true

  tags = {
    Name = "myapp-subnet-2"
  }
}


module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name = "myapp-cluster"
  subnets      = [aws_subnet.myapp_subnet_1.id, aws_subnet.myapp_subnet_2.id]

  tags = {
    Terraform = "true"
    Environment = "dev"
  }


  vpc_id = aws_vpc.myapp_vpc.id

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t2.micro"]

      min_size     = 1
      max_size     = 10
      desired_size = 1
    }
  }
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

