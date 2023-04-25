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

resource "local_file" "kubeconfig" {
  filename = "${path.root}/kubeconfig_${local.cluster_name}"
  source = module.eks.kubeconfig_output_path
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
