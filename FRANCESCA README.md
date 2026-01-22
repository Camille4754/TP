[README.md](https://github.com/user-attachments/files/24789430/README.md)
# ☁️ CloudMemo - Infrastructure SysOps Multi-OS

## 📝 Présentation

CloudMemo est une application de prise de notes basée sur **Flask** et **Redis**, déployée dans un **cluster Kubernetes**.
Le projet vise à créer un environnement **multi-tenant sécurisé**, pour deux équipes (Blue et Green), avec une **automatisation complète**.

---

## 🏗️ Architecture

L’infrastructure repose sur un environnement hétérogène piloté par le code :

* **Station de Contrôle :** Debian (Héberge Ansible et Docker pour le build)
* **Cluster Kubernetes :** Ubuntu (1 Master, 1 Worker)
* **Isolation :** Namespaces et Network Policies stricts

---

## 🚀 Déploiement

### 1️⃣ Préparation de l’infrastructure (Ansible)

Depuis la machine Debian, provisionner les nœuds Ubuntu :

```bash
cd ~/SysOps/ansible
ansible-playbook -i inventory.ini playbook.yml
```

> Désactive le Swap, Installe les pré-requis, Containerd, Kubernetes et initialise le cluster.

### 2️⃣ Build et Push de l’image Docker

Toujours sur la VM Ansible (Debian) :

```bash
cd cloudmemo-docker
docker build -t franeka/cloudmemo:v1.0 .
docker push franeka/cloudmemo:v1.0
```

### 3️⃣ Déploiement Kubernetes

Sur le Master Ubuntu, appliquez les manifestes dans cet ordre :

```bash
cd ~/SysOps/ansible/cloudmemo-k8s
kubectl apply -f 01-namespaces.yaml
kubectl apply -f 02-redis.yaml
kubectl apply -f 03-app.yaml
kubectl apply -f 04-network-policies.yaml
```

---

## 🤖 Automatisation (Ansible)

Les playbooks gèrent :

* **Installation complète** : Kubeadm, Kubelet, Kubectl
* **Idempotence** : Garantit un état stable, quel que soit l’OS

---

## 📦 Conteneurisation (Docker)

* **Image :** `franeka/cloudmemo:v1.0`
* **Validation :** Test via `docker-compose` pour vérifier la liaison avec Redis avant déploiement

---

## ☸️ Orchestration Kubernetes

* **Namespaces :** `team-blue` et `team-green`
* **Services NodePort :**

  * Team Blue → port 30001
  * Team Green → port 30002

---

## 🔒 Sécurité (Network Policies)

* **Default Deny** : Blocage du trafic inter-namespace
* **Port Whitelisting** : Seule l’application Flask communique avec Redis (port 6379)

---

## 📁 Structure du dépôt

```
SysOps/
└── ansible/
    ├── inventory.ini             # Inventaire des nœuds Ubuntu
    ├── playbook.yml              # Playbook d'installation du cluster
    ├── cloudmemo-docker/         # Build Docker sur Debian
    │   ├── app.py                # Application Flask
    │   ├── docker-compose.yml    # Test local
    │   ├── dockerfile            # Recette de l'image
    │   └── requirements.txt      # Librairies Python
    └── cloudmemo-k8s/            # Manifestes Kubernetes
        ├── 01-namespaces.yaml    # Isolation logique
        ├── 02-redis.yaml         # Services de données
        ├── 03-app.yaml           # Déploiement applicatif
        └── 04-network-policies.yaml # Pare-feu interne
```

---

## 🧪 Tests et validation

* **Accessibilité :** http://`<IP_WORKER_UBUNTU>`:30001
* **Isolation :** Une note sur Blue n’apparaît pas sur Green
* **Sécurité :** Le trafic entre namespaces est bloqué par les Network Policies
