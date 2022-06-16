variable "name" {
  description = "Pass the name of the cluster"
  type        = string
  default     = ""

}
variable "version" {
  description = "Pass Kubernetes version"
  type        = string
  default     = " "
}
variable "subnetId" {
  description = "Pass subnet ids "
  type        = list(string)
  default     = []
}
variable "sgId" {
  description = "Pass security groups"
  type        = list(string)
  default     = []
}
variable "cidr" {
  description = "Pass CIDR range for public access to the cluster"
  type        = string
  default     = []
}
variable "eks_tagName" {
  description = "Pass tag names"
  type        = map(string)
  default     = {}
}
