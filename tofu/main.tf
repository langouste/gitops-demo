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
  count           = 2  # Crée 2 VMs : vm_tp.0 et vm_tp.1
  name  = count.index == 0 ? "swarm-manager" : "swarm-worker-${count.index}"
  image_name      = "Ubuntu 24.04"
  flavor_name     = "d2-2" # Instance légère
  key_pair        = openstack_compute_keypair_v2.tp_key.name
  security_groups = ["default"]

  network {
    name = "Ext-Net"
  }
}

output "instances_ips" {
  value = openstack_compute_instance_v2.vm_tp[*].access_ip_v4
}
