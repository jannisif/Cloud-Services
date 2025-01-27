###########################################################################
# Network
###########################################################################
# Erstellung des "vlan"
resource "openstack_networking_network_v2" "terraform-network-1" { 
  name           = "projekt-net"
  admin_state_up = "true"
}
resource "openstack_networking_subnet_v2" "terraform-subnet-1" {
  name            = "projekt-subnet"
  network_id      = openstack_networking_network_v2.terraform-network-1.id
  cidr            = "192.168.254.0/24"
  ip_version      = 4
  dns_nameservers = local.dns_servers
}
# Router wird durch OpenStack "zur Verfügung gestellt"
data "openstack_networking_router_v2" "router-1" {
  name = local.router_name
}
resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = data.openstack_networking_router_v2.router-1.id
  subnet_id = openstack_networking_subnet_v2.terraform-subnet-1.id
}
###########################################################################
# Ports
###########################################################################
# Port mgmt
resource "openstack_networking_port_v2" "port_mgmt" {
  name           = "port_mgmt"
  network_id     = openstack_networking_network_v2.terraform-network-1.id
  admin_state_up = "true"
  fixed_ip {
    subnet_id    = openstack_networking_subnet_v2.terraform-subnet-1.id
    ip_address   = "192.168.254.10"
  }
}
# Port node1
resource "openstack_networking_port_v2" "port_node-1" {
  name           = "port_node-1"
  network_id     = openstack_networking_network_v2.terraform-network-1.id
  admin_state_up = "true"
    fixed_ip {
    subnet_id    = openstack_networking_subnet_v2.terraform-subnet-1.id
    ip_address   = "192.168.254.21"
  }
}
# Port node2
resource "openstack_networking_port_v2" "port_node-2" {
  name           = "port_node-2"
  network_id     = openstack_networking_network_v2.terraform-network-1.id
  admin_state_up = "true"
  fixed_ip {
    subnet_id    = openstack_networking_subnet_v2.terraform-subnet-1.id
    ip_address   = "192.168.254.22"
  }
}
# Port node3
resource "openstack_networking_port_v2" "port_node-3" {
  name           = "port_node-3"
  network_id     = openstack_networking_network_v2.terraform-network-1.id
  admin_state_up = "true"
  fixed_ip {
    subnet_id    = openstack_networking_subnet_v2.terraform-subnet-1.id
    ip_address   = "192.168.254.23"
  }
}

###########################################################################
# Security Group
###########################################################################
resource "openstack_networking_secgroup_v2" "terraform-secgroup" {
  name        = "Konstruct-secgroup"
  description = "Konstruct"
}
# Web
resource "openstack_networking_secgroup_rule_v2" "terraform-secgroup-rule-http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  #remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.terraform-secgroup.id
}
# SSH
resource "openstack_networking_secgroup_rule_v2" "terraform-secgroup-rule-ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.terraform-secgroup.id
}
# Paperless Port 8000
resource "openstack_networking_secgroup_rule_v2" "terraform-secgroup-rule-plngx" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8000
  port_range_max    = 8000
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.terraform-secgroup.id
}

###########################################################################
# assign floating ip to instance 
###########################################################################
data "openstack_networking_port_v2" "port-1" {
  fixed_ip = openstack_compute_instance_v2.node1.access_ip_v4
}
resource "openstack_networking_floatingip_v2" "fip_1" {
  pool    = local.pubnet_name
  port_id = data.openstack_networking_port_v2.port-1.id
}
output "docker_vip_addr" {
  value = openstack_networking_floatingip_v2.fip_1
}