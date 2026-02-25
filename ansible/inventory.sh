#!/bin/bash
# Récupère l'IP depuis le state de Tofu (on remonte d'un dossier)
IP=$(cd ../tofu && tofu output -raw instance_ip)

# Génère le JSON attendu par Ansible
echo "{
  \"all\": {
    \"hosts\": [\"$IP\"]
  },
  \"_meta\": {
    \"hostvars\": {
      \"$IP\": {
        \"ansible_user\": \"ubuntu\"
      }
    }
  }
}"