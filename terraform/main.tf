provider "kubernetes" {
  config_path = "kubeconfig.yaml"
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

resource "aws_subnet" "myapp_subnet" {
  vpc_id     = aws_vpc.myapp_vpc.id
  cidr_block = "10.1.1.0/24"

  tags = {
    Name        = "myapp-subnet"
    Environment = var.env_prefix
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name = local.cluster_name
  subnet_ids   = [aws_subnet.myapp_subnet.id]

  tags = {
    Terraform   = "true"
    Environment = var.env_prefix
  }

  vpc_id = aws_vpc.myapp_vpc.id

  eks_managed_node_group_defaults = {
    desired_capacity = 2
    max_capacity     = 10
    min_capacity     = 1

    instance_types = ["t3.micro"]
  }
}

resource "local_file" "kubeconfig" {
  filename = "kubeconfig.yaml"
  content  = module.eks.kubeconfig
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
