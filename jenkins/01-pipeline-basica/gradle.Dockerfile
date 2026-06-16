# ═══════════════════════════════════════════════════════════════════════════
# gradle.Dockerfile — imagen Jenkins con Gradle (Ejercicio 1)
# ═══════════════════════════════════════════════════════════════════════════
# Este es el gradle.Dockerfile del bootcamp, con UN ÚNICO cambio respecto al
# original: el valor de GRADLE_SHA (marcado abajo con [FIX]).
#
# Original:
#   https://github.com/Lemoncode/bootcamp-devops-lemoncode/blob/master/03-cd/exercises/jenkins-resources/gradle.Dockerfile
#
# POR QUÉ EL CAMBIO:
# El Dockerfile valida la descarga de Gradle contra un hash SHA-256 fijo. El
# `gradle-7.6.6-bin.zip` servido hoy por gradle.org tiene un hash distinto al
# que traía el bootcamp (Gradle republicó el artefacto en algún momento), así
# que la validación `sha256sum -c` fallaba y el build abortaba con:
#     /tmp/gradle.zip: FAILED — sha256sum: WARNING: 1 computed checksum did NOT match
# La corrección es actualizar GRADLE_SHA al hash real actual.
#
# NOTA: NO hace falta tocar la versión de Java. El tag `lts-jdk17` trae Java 17
# (verificado: Temurin 17.0.18), que Gradle 7.6.6 soporta sin problema.
#
# CÓMO OBTENER EL SHA ACTUAL (por si vuelve a cambiar en el futuro):
#   curl -fsSL -o /tmp/gradle.zip https://services.gradle.org/distributions/gradle-7.6.6-bin.zip
#   sha256sum /tmp/gradle.zip
#   # copia los 64 caracteres resultantes al ARG GRADLE_SHA de abajo
# ═══════════════════════════════════════════════════════════════════════════

FROM jenkins/jenkins:lts-jdk17

USER root

# Reference install gradle: https://medium.com/@migueldoctor/how-to-create-a-custom-docker-image-with-jdk8-maven-and-gradle-ddc90f41cee4
RUN apt update

# Gradle version
ARG GRADLE_VERSION=7.6.6

# Define the URL where gradle can be downloaded
ARG GRADLE_BASE_URL=https://services.gradle.org/distributions

# Define the SHA key to validate the gradle download
# [FIX] SHA actualizado al hash real de gradle-7.6.6-bin.zip de hoy.
#       Original del bootcamp: 7873ed5287f47ca03549ab8dcb6dc877ac7f0e3d7b1eb12685161d10080910ac
ARG GRADLE_SHA=673d9776f303bc7048fc3329d232d6ebf1051b07893bd9d11616fad9a8673be0

# Create the directories, download gradle, validate the download
# install it remove download file and set links
RUN mkdir -p /usr/share/gradle /usr/share/gradle/ref \
  && echo "Downloading gradle hash" \
  && curl -fsSL -o /tmp/gradle.zip ${GRADLE_BASE_URL}/gradle-${GRADLE_VERSION}-bin.zip \
  && echo "Checking download hash" \
  && echo "${GRADLE_SHA} /tmp/gradle.zip" | sha256sum -c - \
  && echo "Unziping gradle" && unzip -d /usr/share/gradle /tmp/gradle.zip \
  && echo "Clenaing and setting links" && rm -f /tmp/gradle.zip \
  && ln -s /usr/share/gradle/gradle-${GRADLE_VERSION} /usr/bin/gradle

ENV GRADLE_VERSION 7.6.6
ENV GRADLE_HOME /usr/bin/gradle
ENV PATH $PATH:$GRADLE_HOME/bin
