###########################################################################
# Security Group Portfreigaben
###########################################################################
# Security Group Name
resource "openstack_networking_secgroup_v2" "sicgru" {
  name        = "secgroupforproject"
  description = "Sec Group for Project PaperlessNGX"
}
###########################################################################
# SSH & Paperless Webinterface
resource "openstack_networking_secgroup_rule_v2" "sicgru-rule-ssh-plngx" {
  direction         = "ingress"
  ethertype        = "IPv4"
  protocol         = "tcp"
  port_range_min   = 22
  port_range_max   = 22
  security_group_id = openstack_networking_secgroup_v2.sicgru.id
}
resource "openstack_networking_secgroup_rule_v2" "sicgru-rule-plngx" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8000
  port_range_max    = 8000
  security_group_id = openstack_networking_secgroup_v2.sicgru.id
}

###########################################################################
# GlusterFS Management, Inter-Node Kommunikation & Bricks
resource "openstack_networking_secgroup_rule_v2" "sicgru-rule-gluster-mgm-tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 24007
  port_range_max    = 24007
  security_group_id = openstack_networking_secgroup_v2.sicgru.id
}
resource "openstack_networking_secgroup_rule_v2" "sicgru-rule-gluster-mgm-udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 24007
  port_range_max    = 24007
  security_group_id = openstack_networking_secgroup_v2.sicgru.id
}
###########################################################################
resource "openstack_networking_secgroup_rule_v2" "sicgru-rule-gluster-comm-tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 24008
  port_range_max    = 24008
  security_group_id = openstack_networking_secgroup_v2.sicgru.id
}
resource "openstack_networking_secgroup_rule_v2" "sicgru-rule-gluster-udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = 24008
  port_range_max    = 24008
  security_group_id = openstack_networking_secgroup_v2.sicgru.id
}
###########################################################################
resource "openstack_networking_secgroup_rule_v2" "sicgru-rule-gluster-bricks" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 49152
  port_range_max    = 49156
  security_group_id = openstack_networking_secgroup_v2.sicgru.id
}
###########################################################################
resource "openstack_networking_secgroup_rule_v2" "sicgru-rule-cluster-internal" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_ip_prefix  = "192.168.254.0/24"
  security_group_id = openstack_networking_secgroup_v2.sicgru.id
}
