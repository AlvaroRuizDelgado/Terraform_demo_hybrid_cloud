output "elb_dns_name" {
  value = "${aws_elb.example-lb.dns_name}"
}
