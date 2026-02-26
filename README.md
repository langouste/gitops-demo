# Demo GitOps

GitOps demo with OpenTofu, Ansible & Docker Swarm

## Requirements

### A installer

`pip install -r requirements.txt`
`snap install --classic opentofu`

### Backend s3 si jamais crée

`openstack ec2 credentials create`
`sudo apt update && sudo apt install awscli -y`
`aws s3 mb s3://gitops --endpoint-url https://s3.sbg.perf.cloud.ovh.net`

### Crédentials

Récuperer le fichier openrc.sh avec les identifiants du provisioneur cloud.

## Getting started

`source openrc.sh && source .venv/bin/activate`

```bash
cd tofu
tofu init
tofu plan
tofu apply
```

### via script run.sh

le script lance tofu, ansible et docker swarm
`./run.sh`

### via scirpt run-v2.sh

même chose mais en utilisant les template jinja pour la stask app docker


Voici une version structurée, propre et professionnelle de votre fichier **README.md**. J'ai corrigé les coquilles (comme le `.neto` dans l'URL S3) et ajouté quelques précisions pour rendre l'expérience utilisateur plus fluide.

---

# 🚀 Demo GitOps : OpenTofu, Ansible & Docker Swarm

Ce dépôt présente une démonstration complète d'un workflow **GitOps** et **Infrastructure as Code (IaC)**. Il permet de provisionner des instances sur OVHcloud avec **OpenTofu**, de les configurer avec **Ansible**, et de déployer une stack applicative sur un cluster **Docker Swarm**.

---

## 📋 Prérequis

### 1. Installation des outils

Assurez-vous d'avoir les outils nécessaires sur votre machine locale :

* **Python & Dépendances** :
```bash
# Création et activation de l'environnement virtuel
python3 -m venv .venv
source .venv/bin/activate
# Installation des modules (Ansible, OpenStack SDK)
pip install -r requirements.txt

```


* **OpenTofu** :
```bash
snap install --classic opentofu

```



### 2. Configuration du Backend S3 (Remote State)

Pour partager l'état de l'infrastructure (`.tfstate`), nous utilisons l'Object Storage d'OVHcloud. Si le bucket n'existe pas encore :

1. **Générer les accès S3** :
```bash
openstack ec2 credentials create

```

Notez les identifiants obtenus.


2. **Créer le bucket via l'AWS CLI** :
```bash
# Installation (si besoin)
sudo apt update && sudo apt install awscli -y

# Création du bucket (Remplacez sbg par votre région)
aws s3 mb s3://gitops-demo --endpoint-url https://s3.sbg.perf.cloud.ovh.net

```


### 3. Authentification Cloud

Téléchargez votre fichier `openrc.sh` depuis l'interface OVHcloud (Public Cloud > Users & Roles) pour permettre aux outils de communiquer avec l'API OpenStack.


### 4. Variables d'environnement pour le Backend S3

Pour qu'OpenTofu puisse s'authentifier auprès de l'Object Storage d'OVHcloud, vous devez exporter vos identifiants S3 :

```bash
# Identifiants S3 pour le stockage du .tfstate
export AWS_ACCESS_KEY_ID="votre_access_key"
export AWS_SECRET_ACCESS_KEY="votre_secret_key"

```

Ces deux lignes peuvent être ajoutées à votre openrc.sh pour être chargées avec les autres variables d'envrionnement.

---

## 🛠️ Getting Started

### 1. Préparation de l'environnement

Avant toute action, chargez vos variables d'environnement :

```bash
source openrc.sh
source .venv/bin/activate

```

### 2. Déploiement manuel (OpenTofu)

Si vous souhaitez gérer l'infrastructure pas à pas :

```bash
cd tofu
tofu init    # Initialise le backend S3
tofu plan    # Visualise les changements
tofu apply   # Déploie les instances

```

---

## 🤖 Automatisation via Scripts

Pour simplifier le workflow, deux scripts d'automatisation sont à votre disposition. Ils enchaînent le provisioning (Tofu), la configuration (Ansible) et l'initialisation du cluster Swarm.

### Option A : Déploiement standard (`run.sh`)

Lance la séquence complète avec une configuration Docker Stack statique.

```bash
chmod +x run.sh
./run.sh

```

### Option B : Déploiement avec Templates (`run-v2.sh`)

Cette version utilise des **templates Jinja2** pour injecter dynamiquement l'IP des instances dans la configuration de la stack Docker (via Ansible).

```bash
chmod +x run-v2.sh
./run-v2.sh

```

---

## 📁 Structure du projet

* `/tofu` : Fichiers de configuration de l'infrastructure (Instances, Network, SecGroups).
* `/ansible` : Playbooks de configuration des nœuds et du cluster Swarm.
* `/ansible/templates` : Templates Jinja2 pour les fichiers de stack Docker.
* `/docker` : Fichiers de configuration des Stack Docker Swarm (Traefik, Whoami).
* `inventory.sh` : Script d'inventaire dynamique pour lier Tofu à Ansible.

---

> **Note** : N'oubliez pas de configurer vos **GitHub Secrets** (OpenRC, S3 Keys, SSH Private Key) si vous souhaitez utiliser ce dépôt avec GitHub Actions.
