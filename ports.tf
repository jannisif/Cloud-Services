###########################################################################
# Ports
###########################################################################
# Port mgmt
resource "openstack_networking_port_v2" "port_mgm" {
  name           = "port_mgm"
  network_id     = openstack_networking_network_v2.terraform-network-1.id
  admin_state_up = "true"
  security_group_ids = [openstack_networking_secgroup_v2.sicgru.id]
  fixed_ip {
    subnet_id    = openstack_networking_subnet_v2.terraform-subnet-1.id
    ip_address   = "192.168.254.20"
  }
}
###########################################################################
# Port node1
resource "openstack_networking_port_v2" "port_node-1" {
  name           = "port_node-1"
  network_id     = openstack_networking_network_v2.terraform-network-1.id
  admin_state_up = "true"
  security_group_ids = [openstack_networking_secgroup_v2.sicgru.id]
  fixed_ip {
    subnet_id    = openstack_networking_subnet_v2.terraform-subnet-1.id
    ip_address   = "192.168.254.21"
  }
}
###########################################################################
# Port node2
resource "openstack_networking_port_v2" "port_node-2" {
  name           = "port_node-2"
  network_id     = openstack_networking_network_v2.terraform-network-1.id
  security_group_ids = [openstack_networking_secgroup_v2.sicgru.id]
  admin_state_up = "true"
  fixed_ip {
    subnet_id    = openstack_networking_subnet_v2.terraform-subnet-1.id
    ip_address   = "192.168.254.22"
  }
}
###########################################################################
# Port node3
resource "openstack_networking_port_v2" "port_node-3" {
  name           = "port_node-3"
  network_id     = openstack_networking_network_v2.terraform-network-1.id
  security_group_ids = [openstack_networking_secgroup_v2.sicgru.id]
  admin_state_up = "true"
  fixed_ip {
    subnet_id    = openstack_networking_subnet_v2.terraform-subnet-1.id
    ip_address   = "192.168.254.23"
  }
}