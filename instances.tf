###########################################################################
# Erstellen der Instanzen
###########################################################################

# Instanz Management
resource "openstack_compute_instance_v2" "management" {
  name              = "mgmt"
  image_name        = local.image_name
  flavor_name       = local.flavor_name
  key_pair          = openstack_compute_keypair_v2.terraform-keypair.name
  security_groups   = [openstack_networking_secgroup_v2.terraform-secgroup.name]
  depends_on = [openstack_networking_subnet_v2.terraform-subnet-1]
  network {
    #uuid = openstack_networking_network_v2.terraform-network-1.id
    port = openstack_networking_port_v2.port_mgmt.id
  }
  user_data = file("./skripte/mgmt.sh")
} 

###########################################################################
# Nodes (Paperless und GlusterFS) -  anpassbar

# file("./skripte/xxx.sh"
###########################################################################
# resource "openstack_compute_instance_v2" "node" {
#  name              = "node"
#  count             = 1
#  image_name        = local.image_name
#  flavor_name       = local.flavor_name
#  key_pair          = openstack_compute_keypair_v2.terraform-keypair.name
#  security_groups   = [openstack_networking_secgroup_v2.terraform-secgroup.name]
#  depends_on = [openstack_networking_subnet_v2.terraform-subnet-1]
#  network {
#    port = openstack_networking_port_v2.port_nas-1.id
#  }
#  user_data = templatefile("./skripte/instanz.sh.tftpl", {
#    node1_ipv4 = openstack_networking_port_v2.port_nas-1.fixed_ip_v4,
#    node2_ipv4 = openstack_networking_port_v2.port_nas-2.fixed_ip_v4,
#    node3_ipv4 = openstack_networking_port_v2.port_nas-3.fixed_ip_v4
#  })
#}


# Node1
resource "openstack_compute_instance_v2" "node1" {
  name              = "node1"
  image_name        = local.image_name
  flavor_name       = local.flavor_name
  key_pair          = openstack_compute_keypair_v2.terraform-keypair.name
  security_groups   = [openstack_networking_secgroup_v2.terraform-secgroup.name]
  depends_on = [openstack_networking_subnet_v2.terraform-subnet-1]
  network {
    #uuid = openstack_networking_network_v2.terraform-network-1.id
    port = openstack_networking_port_v2.port_node-1.id
  }
  user_data = file("./skripte/node1.sh")
} 

# Node2
resource "openstack_compute_instance_v2" "node2" {
  name              = "node2"
  image_name        = local.image_name
  flavor_name       = local.flavor_name
  key_pair          = openstack_compute_keypair_v2.terraform-keypair.name
  security_groups   = [openstack_networking_secgroup_v2.terraform-secgroup.name]
  depends_on = [openstack_networking_subnet_v2.terraform-subnet-1]
  network {
    #uuid = openstack_networking_network_v2.terraform-network-1.id
    port = openstack_networking_port_v2.port_node-2.id
  }
  user_data = file("./skripte/node2.sh")
}

# Node3
resource "openstack_compute_instance_v2" "node3" {
  name              = "node3"
  image_name        = local.image_name
  flavor_name       = local.flavor_name
  key_pair          = openstack_compute_keypair_v2.terraform-keypair.name
  security_groups   = [openstack_networking_secgroup_v2.terraform-secgroup.name]
  depends_on = [openstack_networking_subnet_v2.terraform-subnet-1]
  network {
    #uuid = openstack_networking_network_v2.terraform-network-1.id
    port = openstack_networking_port_v2.port_node-3.id
  }
  user_data = file("./skripte/node3.sh")
} 