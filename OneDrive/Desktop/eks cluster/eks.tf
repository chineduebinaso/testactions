#create eks cluster
resource "aws_eks_cluster" "demo" {
  name     = "demo"
  role_arn = data.terraform_remote_state.vpc.outputs.node_role


  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    subnet_ids = [
      data.terraform_remote_state.vpc.outputs.private[0], data.terraform_remote_state.vpc.outputs.public[0],
      data.terraform_remote_state.vpc.outputs.private[1], data.terraform_remote_state.vpc.outputs.public[1]
    ]
  }
}