## ===== Resource for EKS service role ===== ##
resource "aws_iam_role" "eksClusterRole" {
  name               = eksClusterRole
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

## ===== Resource for policy attachment ===== ##
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eksClusterRole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eksClusterRole.name
}
resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eksClusterRole.name
}


## ===== Resource for AWS EKS ===== ##
resource "aws_eks_cluster" "eksCluster" {
  name     = var.name
  version  = var.version
  role_arn = aws_iam_role.eksClusterRole.arn
  vpc_config {
    subnet_ids              = var.subnetId
    security_group_ids      = var.sgId
    endpoint_private_access = false
    endpoint_public_access  = true
    public_access_cidr      = var.cidr

  }
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
  ]
  tags = merge(var.eks_tagName)
}
