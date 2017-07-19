# output "elb_dns_name" {
#   value = "${aws_elb.example-lb.dns_name}"
# }

output "LB IP address" {
  value = "${openstack_networking_floatingip_v2.lb_fip.address}"
}
