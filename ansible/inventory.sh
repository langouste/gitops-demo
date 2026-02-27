#!/bin/bash

# Récupération des IPs depuis OpenTofu (format JSON)
# On suppose que ton output s'appelle "instances_ips" et contient une liste d'IPs
IPS_JSON=$(cd ../tofu; tofu output -json instances_ips)

# Extraction des IPs avec jq
# La première IP (index 0) sera le manager
MANAGER_IP=$(echo $IPS_JSON | jq -r '.[0]')
# Les autres IPs (index 1 et suivants) seront les workers
WORKER_IPS=$(echo $IPS_JSON | jq -r '. [1:] | .[]')

# Génération du JSON pour Ansible
if [ "$1" == "--list" ]; then
  cat <<EOF
{
  "manager": {
    "hosts": ["$MANAGER_IP"]
  },
  "workers": {
    "hosts": [
      $(echo "$WORKER_IPS" | sed 's/.*/"&"/' | paste -sd "," -)
    ]
  },
  "_meta": {
    "hostvars": {
      $(echo "$MANAGER_IP" | sed "s/.*/\"&\": { \"ansible_host\": \"&\", \"ansible_user\": \"ubuntu\" }/")
      $(if [ ! -z "$WORKER_IPS" ]; then echo ","; fi)
      $(echo "$WORKER_IPS" | sed 's/.*/"&": { "ansible_host": "&", "ansible_user": "ubuntu" }/' | paste -sd "," -)
    }
  }
}
EOF
elif [ "$1" == "--host" ]; then
  echo '{"_meta": {"hostvars": {}}}'
else
  echo "Usage: $0 --list"
  exit 1
fi