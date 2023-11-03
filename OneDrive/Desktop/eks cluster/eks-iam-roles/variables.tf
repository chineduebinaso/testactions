variable "node_role_name" {
    description = "Name of the IAM role for nodes"
    type = string
    default = "eks-node-group-nodes"
}

variable "cluster_role_name" { 
    description = "Name of the IAM role for the EKS cluster"
    type = string
    default = "eks-cluster-demo"
}