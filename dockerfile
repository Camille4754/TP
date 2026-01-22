# Utiliser une image Python officielle légère (slim)
FROM python:3.11-slim

# Définir le répertoire de travail dans le conteneur
WORKDIR /app

# Installer les dépendances système nécessaires (si besoin pour certaines libs)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copier le fichier des dépendances en premier pour profiter du cache Docker
COPY requirements.txt .

# Installer les bibliothèques Python définies dans le sujet
# (Flask, redis, google-cloud-storage)
RUN pip install --no-cache-dir -r requirements.txt

# Copier l'intégralité du code source (app.py, etc.) dans le conteneur
COPY . .

# L'application Flask écoute par défaut sur le port 5000
EXPOSE 5000

# Commande pour démarrer l'application
# On utilise l'écoute sur 0.0.0.0 pour que le trafic externe (Docker/K8s) soit accepté
CMD ["python", "app.py"]