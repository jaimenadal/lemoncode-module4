# ═══════════════════════════════════════════════════════════════════════════
# Dockerfile — host Jenkins para el Ejercicio 2 (runner Docker)
# ═══════════════════════════════════════════════════════════════════════════
# Imagen de Jenkins preparada para lanzar contenedores (Docker-in-Docker vía
# socket del host). A diferencia del ejercicio 1, este Jenkins NO necesita
# Gradle: solo orquesta. Lo que sí necesita es:
#   - el CLI de Docker (para hablar con el socket montado)
#   - los plugins Docker + Docker Pipeline (para la sintaxis agent { docker {} })
#
# Todo se declara aquí en lugar de instalarse a mano tras arrancar, de modo que
# el entorno es reproducible: quien construya esta imagen tiene todo listo.
#
# La versión de Java de esta imagen es indiferente: la compilación ocurre dentro
# del contenedor gradle:6.6.1-jre14-openj9, que trae su propio Java 14.
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
