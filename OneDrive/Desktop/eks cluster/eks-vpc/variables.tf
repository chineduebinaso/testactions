variable "region" {
  default = "us-east-1"
}

variable "private_cidr" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_cidr" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "availability_zone" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]

}