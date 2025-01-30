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
###########################################################################
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
###########################################################################
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
###########################################################################
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
# Security Group Portfreigaben
###########################################################################
# Security Group Name
resource "openstack_networking_secgroup_v2" "terraform-secgroup2" {
  name        = "Konstruct-secgroup2"
  description = "Konstruct"
}
###########################################################################
# SSH Portfreigabe
resource "openstack_networking_secgroup_rule_v2" "terraform-secgroup-rule-ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.terraform-secgroup2.id
}
###########################################################################
# Paperless Portfreigabe
resource "openstack_networking_secgroup_rule_v2" "terraform-secgroup-rule-plngx" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8000
  port_range_max    = 8000
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.terraform-secgroup2.id
}
###########################################################################
# GlusterFS Management (TCP/UDP 24007) Portfreigabe
resource "openstack_networking_secgroup_rule_v2" "terraform-secgroup-rule-gluster-mgmt" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 24007
  port_range_max    = 24007
  security_group_id = openstack_networking_secgroup_v2.terraform-secgroup2.id
}
resource "openstack_networking_secgroup_rule_v2" "terraform-secgroup-rule-gluster-mgmt-udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 24007
  port_range_max    = 24007
  security_group_id = openstack_networking_secgroup_v2.terraform-secgroup2.id
}
 ###########################################################################
# GlusterFS Inter-Node Kommunikation (TCP/UDP 24008)Portfreigabe
resource "openstack_networking_secgroup_rule_v2" "terraform-secgroup-rule-gluster-comm" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 24008
  port_range_max    = 24008
  security_group_id = openstack_networking_secgroup_v2.terraform-secgroup2.id
}
resource "openstack_networking_secgroup_rule_v2" "terraform-secgroup-rule-gluster-comm-udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 24008
  port_range_max    = 24008
  security_group_id = openstack_networking_secgroup_v2.terraform-secgroup2.id
}
###########################################################################
# GlusterFS Brick Ports (TCP 49152 - 49156 für 5 Bricks)Portfreigabe
resource "openstack_networking_secgroup_rule_v2" "terraform-secgroup-rule-gluster-brick" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 49152
  port_range_max    = 49156
  security_group_id = openstack_networking_secgroup_v2.terraform-secgroup2.id
}
###########################################################################
# Kommunikation zwischen GlusterFS-Nodes zulassen (Cluster-Netzwerk)Portfreigabe
resource "openstack_networking_secgroup_rule_v2" "terraform-secgroup-rule-gluster-internal" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "192.168.254.0/24"
  security_group_id = openstack_networking_secgroup_v2.terraform-secgroup2.id
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
###########################################################################
###########################################################################
# Load Balancer
resource "openstack_lb_loadbalancer_v2" "plngx_lb" {
  name          = "paperless-lb"
  vip_subnet_id = openstack_networking_subnet_v2.terraform-subnet-1.id
}
resource "openstack_lb_listener_v2" "plngx_listener" {
  name            = "paperless-listener"
  loadbalancer_id = openstack_lb_loadbalancer_v2.plngx_lb.id
  protocol        = "HTTP"
  protocol_port   = 8000
}
resource "openstack_lb_pool_v2" "plngx_pool" {
  name        = "paperless-pool"
  listener_id = openstack_lb_listener_v2.plngx_listener.id
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
}
resource "openstack_lb_member_v2" "node1" {
  pool_id       = openstack_lb_pool_v2.plngx_pool.id
  address       = "192.168.254.21"
  protocol_port = 8000
  subnet_id     = openstack_networking_subnet_v2.terraform-subnet-1.id
}
resource "openstack_lb_member_v2" "node2" {
  pool_id       = openstack_lb_pool_v2.plngx_pool.id
  address       = "192.168.254.22"
  protocol_port = 8000
  subnet_id     = openstack_networking_subnet_v2.terraform-subnet-1.id
}

resource "openstack_lb_member_v2" "node3" {
  pool_id       = openstack_lb_pool_v2.plngx_pool.id
  address       = "192.168.254.23"
  protocol_port = 8000
  subnet_id     = openstack_networking_subnet_v2.terraform-subnet-1.id
}