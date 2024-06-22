variable "vpc_id" {
  description = "ID of the VPC where the Elastic Beanstalk environment will be deployed"
  default = "vpc-0337911341b5e9991"
}

variable "subnet" {
    description = "Subnet ID of first zone"
    default = ["subnet-0f35fd16f743f614f" , "subnet-0337b00a91569670d"]
}