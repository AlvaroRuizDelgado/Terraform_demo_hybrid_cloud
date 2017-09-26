# Having different ports in different clouds shows the flexibility of the LB.
variable "aws_server_port" {
  description = "Port where the AWS webserver is listening."
  default = "8080"
  type = "string"
}

variable "openstack_ext_gw" {
  description = "Identity of the public network."
  default = "280c3727-3403-48de-a507-09753b85595f"
  type = "string"
}

variable "centos7_openstack" {
  description = "Name of the Centos 7 image in OpenStack."
  default = "CentOS-7-x86_64-GenericCloud-1704"
  type = "string"
}

variable "aws_region" {
  description = "AWS region (affects billing)."
  default = "us-west-2"
#  default = "ap-northeast-1"
  type = "string"
}

variable "ubuntu_ami" {
  description = "AMI of Ubuntu in AWS (US-West-2)."
  default = "ami-835b4efa"
#  description = "AMI of Ubuntu in AWS (Tokyo)."
#  default = "ami-ea4eae8c"
  type = "string"
}

variable "gcp_region" {
  description = "GCP region (affects billing)."
  default = "us-central1"
  type = "string"
}

variable "gcp_project" {
  description = "ID of the project to use with terraform."
  default = "project-id-5359646837114259314"
  type = "string"
}

variable "centos7_gcp" {
  description = "Name of the Centos 7 image in GCP."
  default = "centos-7-v20170816"
  type = "string"
}
