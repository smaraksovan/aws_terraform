variable "instancetype" {
  type = string
  default = "t2.large"
}
variable "image_id" {
  type        = string
  description = "The id of the machine image (AMI) to use for the server."
}
variable "keyname"{
    type = string
}
variable "ebstype"{
    type = string
    default = "sc1"
}
variable "ebssize"{
    type = number
}
variable "compute_az" {
  type    = string
  default = "ap-south-1a"
}
variable "publicsubnet1_az" {
  type    = string
  default = "ap-south-1b"
}
variable "publicsubnet2_az" {
  type    = string
#   default = ["ap-south-1c"]
}
variable "pvtsubnet1_az" {
  type    = string
#   default = ["ap-south-1c"]
}
variable "vpc_cidr"{
    # type = string
}
variable "pub_subnetcidr1"{
    # type = string
}
variable "pub_subnetcidr2"{
    # type = string
}
variable "pvt_subnetcidr"{
    # type = string
}
# variable "jumpbox_sg"{
#     # type = string
# }
# variable "webserver_sg"{
#     # type = string

# }
# variable "alb_sg"{
#     # type = string

# }