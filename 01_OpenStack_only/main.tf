# ---------- PROVIDERS -----------

variable "password" {}
variable "user_name" {}
variable "tenant_name" {}
variable "auth_url" {}

provider "openstack" {
  user_name   = "${var.user_name}"
  tenant_name = "${var.tenant_name}"
  password    = "${var.password}"
  auth_url    = "${var.auth_url}"
}

# ------------- OPENSTACK ------------------

resource "openstack_networking_router_v2" "router" {
  name = "demo-router"
  admin_state_up = "true"
  external_gateway = "${var.openstack_ext_gw}"
}

### [Security groups ###

resource "openstack_compute_secgroup_v2" "web_sg" {
  name = "demo-web-sg"
  description = "web security group"
  rule {
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 8080
    to_port = 8080
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 443
    to_port = 443
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = -1
    to_port = -1
    ip_protocol = "icmp"
    cidr = "0.0.0.0/0"
  }
}

### [Web networking] ###

resource "openstack_networking_network_v2" "web_net" {
  name = "demo-web-net"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "web_subnet" {
  name = "demo-web-subnet"
  network_id = "${openstack_networking_network_v2.web_net.id}"
  cidr = "10.0.0.0/24"
  ip_version = 4
  enable_dhcp = "true"
  dns_nameservers = ["8.8.8.8","8.8.4.4"]
}

resource "openstack_networking_router_interface_v2" "web-ext-interface" {
  router_id = "${openstack_networking_router_v2.router.id}"
  subnet_id = "${openstack_networking_subnet_v2.web_subnet.id}"
}

# Networking_floatingip allows to pass a port_id as paramater --> load balancer
resource "openstack_networking_floatingip_v2" "lb_fip" {
  pool = "public"
  port_id = "${openstack_lb_loadbalancer_v2.open_lb.vip_port_id}"
}

### [Load balancer] ###

resource "openstack_lb_loadbalancer_v2" "open_lb" {
  name = "demo-openstack-lb"
  description = "OpenStack load balancer"
  vip_subnet_id = "${openstack_networking_subnet_v2.web_subnet.id}"
}

resource "openstack_lb_listener_v2" "open_lb_listener" {
  name = "demo-openstack-lb-listener"
  description = "Listener element for the OpenStack LB"
  protocol        = "HTTP"
  protocol_port   = 80
  loadbalancer_id = "${openstack_lb_loadbalancer_v2.open_lb.id}"
}

resource "openstack_lb_pool_v2" "open_lb_pool" {
  name = "demo-openstack-lb-pool"
  description = "Pool with the load balancer's servers"
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
  listener_id = "${openstack_lb_listener_v2.open_lb_listener.id}"
}

resource "openstack_lb_member_v2" "open-lb-member" {
  count = 2
  pool_id    = "${openstack_lb_pool_v2.open_lb_pool.id}"
  subnet_id  = "${openstack_networking_subnet_v2.web_subnet.id}"
  address    = "${element(openstack_compute_instance_v2.web_cluster.*.access_ip_v4, count.index)}"
  protocol_port = 80
}

### [Web instances] ###

resource "openstack_compute_servergroup_v2" "web_srvgrp" {
  name = "demo-web-srvgrp"
  policies = ["anti-affinity"]
}

resource "openstack_compute_instance_v2" "web_cluster" {
  name = "demo-web-${count.index+1}"
  count = "2"
  image_name = "${var.centos7_openstack}"
  flavor_name = "m1.tiny"
  network = {
    uuid = "${openstack_networking_network_v2.web_net.id}"
  }
  scheduler_hints {
    group = "${openstack_compute_servergroup_v2.web_srvgrp.id}"
  }
  security_groups = ["${openstack_compute_secgroup_v2.web_sg.name}"]
  user_data = <<-EOF
            #!/bin/bash
            sudo yum install epel-release -y
            sudo yum install nginx -y
            sudo mkdir /usr/share/nginx/demo
            echo "Hello! This is $HOSTNAME on OpenStack" > /usr/share/nginx/demo/index.html
            sudo sed -i 's/\/usr\/share\/nginx\/html/\/usr\/share\/nginx\/demo/g' /etc/nginx/nginx.conf
            sudo systemctl start nginx
            sudo systemctl enable nginx
            EOF
}
