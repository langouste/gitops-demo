terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
}

# Configuration de la clé SSH
resource "openstack_compute_keypair_v2" "tp_key" {
  name       = "tp_iac_key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

# Instance VM
resource "openstack_compute_instance_v2" "vm_tp" {
  name            = "vm-castellengo"
  image_name      = "Ubuntu 24.04"
  flavor_name     = "d2-2" # Instance légère
  key_pair        = openstack_compute_keypair_v2.tp_key.name
  # On référence le nom du groupe networking créé plus haut
  security_groups = ["default"]

  network {
    name = "Ext-Net"
  }
}

output "instance_ip" {
  #value = openstack_compute_instance_v2.vm_tp.access_ip_v4
  value       = openstack_compute_instance_v2.vm_tp.network[0].fixed_ip_v4
}
