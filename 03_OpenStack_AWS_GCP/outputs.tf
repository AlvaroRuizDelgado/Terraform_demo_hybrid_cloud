output "LB IP address" {
  value = "${openstack_networking_floatingip_v2.lb_fip.address}"
}
