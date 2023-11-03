# Data block to read the local VPC tfstate file
data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "../vpc/terraform.tfstate"
  }
}


# Create a node group in the created VPC using the created node role
resource "aws_eks_node_group" "private-nodes" {
  cluster_name    = aws_eks_cluster.demo.name
  node_group_name = "private-nodes"
  node_role_arn   = data.terraform_remote_state.vpc.outputs.demo_role

  subnet_ids = [
    data.terraform_remote_state.vpc.outputs.private[0], data.terraform_remote_state.vpc.outputs.private[1],
    #data.terraform_remote_state.vpc.outputs.public[0], data.terraform_remote_state.vpc.outputs.public[1]
  ]


  capacity_type  = "ON_DEMAND"
  instance_types = ["t2.medium"]

  scaling_config {
    desired_size = 2
    max_size     = 10
    min_size     = 0
  }


  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "devOps"
  }
  # This tags are important if we are going to use an auto-scaler
  tags = {
    "k8s.io/cluster-autoscaler/demo"    = "owned"
    "k8s.io/cluster-autoscaler/enabled" = true

  }
}





