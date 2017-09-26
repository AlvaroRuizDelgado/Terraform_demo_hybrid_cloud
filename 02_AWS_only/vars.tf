variable "server_port" {
  description = "Port where the webserver is listening."
  default = "8080"
  type = "string"
}

variable "aws_region" {
  description = "AWS region (affects billing)."
  default = "us-west-2"
  type = "string"
}

variable "ubuntu_ami" {
  description = "AMI of Ubuntu in AWS (US-West-2)."
  default = "ami-835b4efa"
  type = "string"
}
