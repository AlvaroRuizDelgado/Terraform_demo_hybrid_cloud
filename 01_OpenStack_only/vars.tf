variable "server_port" {
  description = "Port where the webserver is listening."
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
