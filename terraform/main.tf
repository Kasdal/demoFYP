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
  source = "terraform-aws-modules/eks/aws"

  cluster_name = local.cluster_name
  subnets      = [aws_subnet.myapp_subnet.id]

  tags = {
    Terraform   = "true"
    Environment = var.env_prefix
  }

  vpc_id = aws_vpc.myapp_vpc.id

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 20
  }

  node_groups = {
    eks_nodes = {
      desired_capacity = 1
      max_capacity     = 1
      min_capacity     = 1
      instance_type    = "t2.micro"
    }
  }
}

resource "local_file" "kubeconfig" {
  filename = "kubeconfig.yaml"
  content  = module.eks.kubeconfig
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
