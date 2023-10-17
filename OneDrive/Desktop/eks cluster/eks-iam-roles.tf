locals {
  eks_policies = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy",
  ]

  node_policies = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  ]

}

#role and policies for node groups
resource "aws_iam_role" "nodes" {
  name               = "eks-node-group-nodes"
  assume_role_policy = data.aws_iam_policy_document.nodes.json
}



resource "aws_iam_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  name       = "nodes"
  for_each   = toset(local.node_policies)
  policy_arn = each.value
  roles      = [aws_iam_role.nodes.name]

}


#role and policies for eks cluster
resource "aws_iam_role" "demo" {
  name               = "eks-cluster-demo"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json

}

resource "aws_iam_policy_attachment" "demo-AmazonEKSClusterPolicy" {
  name       = "demo"
  for_each   = toset(local.eks_policies)
  policy_arn = each.value
  roles      = [aws_iam_role.demo.name]

}
