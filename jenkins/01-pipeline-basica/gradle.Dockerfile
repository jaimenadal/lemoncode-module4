# ═══════════════════════════════════════════════════════════════════════════
# gradle.Dockerfile — imagen Jenkins con Gradle (Ejercicio 1)
# ═══════════════════════════════════════════════════════════════════════════
# Este es el gradle.Dockerfile del bootcamp, con UN ÚNICO cambio respecto al
# original: el valor de GRADLE_SHA (marcado abajo con [FIX]).
#
# Original:
#   https://github.com/Lemoncode/bootcamp-devops-lemoncode/blob/master/03-cd/exercises/jenkins-resources/gradle.Dockerfile
# CÓMO OBTENER EL SHA ACTUAL (por si vuelve a cambiar):
#   curl -fsSL -o /tmp/gradle.zip https://services.gradle.org/distributions/gradle-7.6.6-bin.zip
#   sha256sum /tmp/gradle.zip
# ═══════════════════════════════════════════════════════════════════════════

FROM jenkins/jenkins:lts-jdk17

USER root

RUN apt update


ARG GRADLE_VERSION=7.6.6


ARG GRADLE_BASE_URL=https://services.gradle.org/distributions

ARG GRADLE_SHA=673d9776f303bc7048fc3329d232d6ebf1051b07893bd9d11616fad9a8673be0

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
