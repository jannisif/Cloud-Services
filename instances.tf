###########################################################################
# Erstellen der Instanzen
###########################################################################
# mgmt
resource "openstack_compute_instance_v2" "management" {
  name              = "mgm"
  image_name        = local.image_name
  flavor_name       = local.flavor_name
  key_pair          = openstack_compute_keypair_v2.terraform-keypair.name
  network {
    port = openstack_networking_port_v2.port_mgmt.id
  }
  user_data = file("./skripte/mgm.sh")
} 
###########################################################################
# Node1
resource "openstack_compute_instance_v2" "node1" {
  name              = "node1"
  image_name        = local.image_name
  flavor_name       = local.flavor_name
  key_pair          = openstack_compute_keypair_v2.terraform-keypair.name
  network {
    port = openstack_networking_port_v2.port_node-1.id
  }
  user_data = file("./skripte/node1.sh")
} 
###########################################################################
# Node2
resource "openstack_compute_instance_v2" "node2" {
  name              = "node2"
  image_name        = local.image_name
  flavor_name       = local.flavor_name
  key_pair          = openstack_compute_keypair_v2.terraform-keypair.name
  network {
    port = openstack_networking_port_v2.port_node-2.id
  }
  user_data = file("./skripte/node2.sh")
}
###########################################################################
# Node3
resource "openstack_compute_instance_v2" "node3" {
  name              = "node3"
  image_name        = local.image_name
  flavor_name       = local.flavor_name
  key_pair          = openstack_compute_keypair_v2.terraform-keypair.name
  network {
    port = openstack_networking_port_v2.port_node-3.id
  }
  user_data = file("./skripte/node3.sh")
} 