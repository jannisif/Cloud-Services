# Provider Config sowie Keypair
################################################################################
# Define CloudServ group number
variable "group_number" {
  type = string
  default = "6"
}
locals {
  auth_url      = "https://private-cloud.informatik.hs-fulda.de:5000/v3"
  user_name     = "CloudServ${var.group_number}"
  user_password = "demo"
  tenant_name   = "CloudServ${var.group_number}"
  cacert_file   = "./os-trusted-cas"
  region_name   = "RegionOne"
  router_name   = "CloudServ${var.group_number}-router"
  dns_servers   = [ "10.33.16.100", "8.8.8.8" ]
  pubnet_name   = "ext_net"
  image_name    = "ubuntu-22.04-jammy-server-cloud-image-amd64"
  flavor_name   = "m1.small"
}
# Define OpenStack provider
terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
       source  = "terraform-provider-openstack/openstack"
      version = "~> 2.0.0"
    }
  }
}
# Configure the OpenStack Provider
provider "openstack" {
  user_name   = local.user_name
  tenant_name = local.tenant_name
  password    = local.user_password
  auth_url    = local.auth_url
  region      = local.region_name
  cacert_file = local.cacert_file
}
# create keypair
resource "openstack_compute_keypair_v2" "terraform-keypair" {
  name       = "projectone"
  #public_key = file("~/.ssh/id_rsa.pub")
}