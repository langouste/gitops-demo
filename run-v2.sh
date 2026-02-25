#!/bin/bash
set -e

echo "🚀 Étape 1 : Provisioning de l'infrastructure..."
cd tofu
tofu apply -auto-approve
export NODE_IP=$(tofu output -raw instance_ip)
cd -

echo "⏳ Etape 2: Attente du démarrage de SSH sur $NODE_IP..."
# On tente une connexion SSH toutes les 5 secondes
# On utilise -o ConnectTimeout pour ne pas rester bloqué
until nc -zvw5 $NODE_IP 22; do
  echo "..."
  sleep 5
done
echo "✅ SSH est disponible !"

echo "🛠️ Étape 3 : Configuration logicielle avec Ansible..."
cd ansible
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i inventory.sh playbook.yml
cd -

echo "🌐 Étape 4 : Déploiement des Stacks Docker..."
cd docker
export DOCKER_HOST=ssh://ubuntu@$NODE_IP
docker stack deploy -c traefik-stack.yml traefik
docker stack deploy -c app-whoami-stack.yml whoami
unset DOCKER_HOST
cd -

ssh ubuntu@$NODE_IP "docker stack deploy -c app-whoami-stack.yml whoami"

echo "L'application est en cours de déploiement sur : http://whoami.$NODE_IP.traefik.me"