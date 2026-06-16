# Jenkins — Ejercicios

Dos pipelines declarativas para un proyecto Java + Gradle (el código fuente es el proyecto Spring Boot `calculator`, que vive en [`Lemoncode/bootcamp-devops-lemoncode`](https://github.com/Lemoncode/bootcamp-devops-lemoncode/tree/master/03-cd/exercises/jenkins-resources/calculator), bajo `03-cd/exercises/jenkins-resources/calculator`).

Ambos pipelines hacen lo mismo —**Checkout → Compile → Unit Tests**— pero ejecutándose en agentes distintos. El primero asume que el host Jenkins ya tiene Java y Gradle; el segundo levanta un contenedor efímero con esas herramientas en cada build, dejando el host Jenkins limpio.

## Notas del montaje (importante)

Los dos ejercicios representan dos filosofías opuestas de **dónde viven las herramientas de build**, y por eso cada uno se ejecuta sobre un Jenkins distinto:

| | Pipeline 1 | Pipeline 2 |
|---|---|---|
| Herramientas | En el agente Jenkins | En un contenedor efímero por build |
| Imagen de Jenkins | `gradle.Dockerfile` del bootcamp (`lts-jdk17`) | `jenkins/jenkins:lts-jdk17` + Docker CLI + plugins |
| Quién compila | El Java del propio Jenkins (Java 17) | El contenedor `gradle:6.6.1-jre14-openj9` (Java 14) |
| ¿Le afecta la versión de Java de Jenkins? | **Sí** (necesita Java 17 para Gradle 7.6.6) | **No** (Jenkins solo orquesta) |

**Pipeline 1 — único fix: el SHA del zip de Gradle.** El `gradle.Dockerfile` del bootcamp funciona con su `FROM jenkins/jenkins:lts-jdk17` tal cual: ese tag trae Java 17 (Temurin 17.0.18), que Gradle 7.6.6 soporta sin problema. El único cambio necesario es actualizar `GRADLE_SHA`: el `gradle-7.6.6-bin.zip` que sirve gradle.org hoy tiene un hash distinto al que traía el bootcamp, y la validación `sha256sum -c` del Dockerfile abortaba el build con `1 computed checksum did NOT match`. El SHA real actual está en [`01-pipeline-basica/gradle.Dockerfile`](01-pipeline-basica/gradle.Dockerfile), con el comando para regenerarlo documentado en sus comentarios.

**Pipeline 2 — usa `lts-jdk17`, y da igual.** Como la compilación ocurre dentro del contenedor `gradle:6.6.1-jre14-openj9` (que trae su propio Java 14), la versión de Java del Jenkins host es irrelevante. 

**Montaje del host del pipeline 2.** Todo el setup (Docker CLI + plugins) se declara en un [`Dockerfile`](02-pipeline-docker-runner/Dockerfile) propio, y el arranque (socket + permisos) en un [`docker-compose.yml`](02-pipeline-docker-runner/docker-compose.yml), de modo que el entorno es reproducible en lugar de configurarse a mano. El Dockerfile instala el CLI de Docker y los plugins:

```dockerfile
FROM jenkins/jenkins:lts-jdk17
USER root
RUN apt-get update && apt-get install -y docker.io && rm -rf /var/lib/apt/lists/*
RUN jenkins-plugin-cli --plugins docker-plugin docker-workflow git
USER jenkins
```

Y el compose lo levanta dando acceso al socket. El **GID del socket no se hardcodea**: se lee de una variable, así el montaje es portable entre máquinas:

```bash
export DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)
docker compose up -d --build
```

```yaml
services:
  jenkins:
    build: { context: ., dockerfile: Dockerfile }
    container_name: jenkins2
    ports: ["8080:8080", "50000:50000"]
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
    group_add:
      - "${DOCKER_GID}"     # GID dueño de docker.sock (portable)
volumes:
  jenkins_home:
```

Por qué cada pieza:
- **Docker CLI dentro del contenedor**: el socket por sí solo no basta; el plugin Docker Pipeline necesita el binario `docker` para hablar con él.
- **`group_add` con el GID del socket**: da al usuario `jenkins` permiso sobre `/var/run/docker.sock`. 


## Ejercicio 1 — Pipeline básica con Gradle en la imagen Jenkins

Jenkinsfile: [`01-pipeline-basica/Jenkinsfile`](01-pipeline-basica/Jenkinsfile)

### Preparación

Construye una imagen de Jenkins que ya traiga Java y Gradle. El `gradle.Dockerfile` del bootcamp ([enlace](https://github.com/Lemoncode/bootcamp-devops-lemoncode/blob/master/03-cd/exercises/jenkins-resources/gradle.Dockerfile)) hace exactamente eso. Suponiendo que lo has descargado a tu directorio actual:

```bash
docker build -t jenkins-gradle:lts -f gradle.Dockerfile .

docker run -d --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins-gradle:lts
```

Abre `http://localhost:8080`, desbloquea con la contraseña que aparece en `docker logs jenkins`, instala los plugins sugeridos y crea el primer usuario admin.

### Ejecución

1. **New Item → Pipeline**, nombre `gradle-pipeline-basica`.
2. En la sección *Pipeline*, selecciona `Pipeline script from SCM`.
3. SCM: Git, URL del repositorio donde subas este Jenkinsfile.
4. Script Path: `jenkins/01-pipeline-basica/Jenkinsfile`.
5. Guarda y pulsa **Build Now**.

Si todo va bien, los tres stages aparecen en verde y el reporte JUnit se publica en la página del build.

## Ejercicio 2 — Pipeline con imagen Docker de Gradle como build runner

Jenkinsfile: [`02-pipeline-docker-runner/Jenkinsfile`](02-pipeline-docker-runner/Jenkinsfile)

Diferencia clave respecto al ejercicio 1: el host Jenkins ya **no necesita** Gradle ni Java. Cada stage corre dentro de un contenedor `gradle:6.6.1-jre14-openj9`, que se descarga la primera vez y se cachea para builds posteriores.

### Preparación

El host Jenkins necesita poder lanzar contenedores Docker (Docker-in-Docker vía el socket) y tener instalados los plugins **Docker** y **Docker Pipeline**. Todo eso está declarado en el [`Dockerfile`](02-pipeline-docker-runner/Dockerfile) y el [`docker-compose.yml`](02-pipeline-docker-runner/docker-compose.yml) de esta carpeta, de modo que no hay que configurar nada a mano tras arrancar.

Desde `jenkins/02-pipeline-docker-runner/`:

```bash
# El GID del socket Docker se lee del host (portable, no hardcodeado)
export DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)

# Construye la imagen (Jenkins + Docker CLI + plugins) y levanta el contenedor
docker compose up -d --build
```

Esto:
- Construye una imagen Jenkins con el **CLI de Docker** y los plugins **docker-plugin** + **docker-workflow** ya instalados (vía `jenkins-plugin-cli` en el Dockerfile).
- Monta `/var/run/docker.sock` para el Docker-in-Docker.
- Añade el GID dueño del socket al usuario `jenkins` con `group_add`, para que tenga permiso de hablar con el socket.

Saca la contraseña inicial y desbloquea Jenkins:
```bash
docker logs jenkins2 2>&1 | grep -A2 "Please use the following password"
```
### Ejecución

Crea el pipeline igual que en el ejercicio 1 (**New Item → Pipeline**, nombre `calculator-ci-docker`, Definition `Pipeline script`), pegando el contenido de [`02-pipeline-docker-runner/Jenkinsfile`](02-pipeline-docker-runner/Jenkinsfile). **Build Now**.

La primera ejecución tarda más porque Docker descarga `gradle:6.6.1-jre14-openj9` (unos 500 MB). De la segunda en adelante usa la imagen cacheada y va rápido.

## Verificar resultados

En ambos pipelines, tras el build:

- Los tres stages aparecen en verde en la **Stage View** de la página del job.
- El tab **Tests** muestra el resumen JUnit (qué tests han corrido y cuántos han pasado).
- En el log de consola debe verse `BUILD SUCCESSFUL` de Gradle al final del stage *Unit Tests*.
