terraform {
  required_providers {
    openstack = {
      source = "terraform-provider-openstack/openstack"
    }
  }
  backend "s3" {
    bucket                      = "castellengo-tofu-state-tp"
    key                         = "terraform.tfstate"
    region                      = "sbg" 
    endpoint                    = "https://s3.sbg.io.cloud.ovh.net/"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true # Important pour la compatibilité S3 hors-AWS
    skip_metadata_api_check     = true
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
  value       = openstack_compute_instance_v2.vm_tp.network[0].fixed_ip_v4
}
