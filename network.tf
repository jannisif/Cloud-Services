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
data "openstack_networking_router_v2" "router-1" {
  name = local.router_name # Router wird durch OpenStack "zur Verfügung gestellt"
}
resource "openstack_networking_router_interface_v2" "router_interface_1" {
  router_id = data.openstack_networking_router_v2.router-1.id
  subnet_id = openstack_networking_subnet_v2.terraform-subnet-1.id
}

###########################################################################
# assign floating ip to instance 
###########################################################################
data "openstack_networking_port_v2" "port-mgm" {
  fixed_ip = openstack_compute_instance_v2.management.access_ip_v4
}
data "openstack_networking_port_v2" "port-node1" {
  fixed_ip = openstack_compute_instance_v2.node1.access_ip_v4
}
###########################################################################
resource "openstack_networking_floatingip_v2" "fip_0" {
  pool    = local.pubnet_name
  port_id = data.openstack_networking_port_v2.port-mgm.id
}
resource "openstack_networking_floatingip_v2" "fip_1" {
  pool    = local.pubnet_name
  port_id = data.openstack_networking_port_v2.port-node1.id
}
###########################################################################
output "docker_mgm_addr" {
  value = openstack_networking_floatingip_v2.fip_0
}
output "docker_node1_addr" {
  value = openstack_networking_floatingip_v2.fip_1
}