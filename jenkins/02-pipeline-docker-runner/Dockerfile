# ═══════════════════════════════════════════════════════════════════════════
# Dockerfile — host Jenkins para el Ejercicio 2 (runner Docker)
# ═══════════════════════════════════════════════════════════════════════════
FROM jenkins/jenkins:lts-jdk17
USER root

# Docker CLI (usa el socket del host montado por docker-compose)
RUN apt-get update && \
    apt-get install -y docker.io && \
    rm -rf /var/lib/apt/lists/*

# Plugins necesarios para Docker Pipeline (jenkins-plugin-cli resuelve versiones
# compatibles con el core de esta imagen, evitando el baile del Update Center)
RUN jenkins-plugin-cli --plugins \
    docker-plugin \
    docker-workflow \
    git

USER jenkins
