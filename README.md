# Módulo 4 — CI/CD

Entregable del **Bootcamp DevOps Lemoncode**. Pipelines con Jenkins (declarativo) y workflows con GitHub Actions, sobre un proyecto Java + Gradle (`calculator`) y sobre el frontend del juego Hangman.

```
lemoncode_module4/
├── README.md                          ← estás aquí
├── GUIA-PRUEBAS.md                    ← guía paso a paso para reproducir y probar todo
├── docs/                              ← capturas de evidencia
├── jenkins/
│   ├── README.md                      ← montaje de Jenkins y ejecución de los pipelines
│   ├── 01-pipeline-basica/
│   │   ├── Jenkinsfile                ← Ejercicio 1: agent any, Gradle en la imagen Jenkins
│   │   └── gradle.Dockerfile          ← imagen Jenkins+Gradle del bootcamp (con SHA actualizado)
│   └── 02-pipeline-docker-runner/
│       ├── Jenkinsfile                ← Ejercicio 2: agent docker con gradle:6.6.1-jre14-openj9
│       ├── Dockerfile                 ← host Jenkins con Docker CLI + plugins
│       └── docker-compose.yml         ← levanta el host con socket Docker y GID portable
└── github-actions/
    ├── README.md                      ← cómo lanzar cada workflow
    ├── .github/workflows/
    │   ├── ci-hangman-front.yml       ← CI obligatorio (PR + paths)
    │   ├── cd-hangman-front.yml       ← CD obligatorio (manual, push a GHCR)
    │   └── e2e-hangman.yml            ← Opcional 3: E2E con Cypress + docker compose
    ├── hangman-front/
    │   └── Dockerfile                 ← réplica del Dockerfile del bootcamp (webpack + nginx :8080)
    └── hangman-e2e/
        └── docker-compose.e2e.yml     ← stack front+api para los tests E2E
```

## Resumen de lo entregado

**Jenkins** — los dos ejercicios obligatorios, ambos como pipeline declarativa con los stages Checkout, Compile y Unit Tests.

- *Ejercicio 1*: usa el `gradle.Dockerfile` del bootcamp (imagen Jenkins con Gradle 7.6.6 preinstalado), con un único fix mínimo: actualizar el `GRADLE_SHA`, porque el `gradle-7.6.6-bin.zip` que sirve gradle.org hoy tiene un hash distinto al que traía el bootcamp y la validación de integridad abortaba el build. El `FROM lts-jdk17` se mantiene intacto: trae Java 17, que Gradle 7.6.6 soporta.
- *Ejercicio 2*: usa la imagen `gradle:6.6.1-jre14-openj9` (Java 14 + OpenJ9) como contenedor efímero por cada build. El host Jenkins no necesita Gradle (la herramienta viaja con su propio Java), pero sí necesita el CLI de Docker y acceso al socket. El montaje del host es reproducible vía `Dockerfile` + `docker-compose.yml`.

**GitHub Actions** — los dos obligatorios (CI + CD del frontend) y uno de los dos opcionales: los **tests E2E con Cypress** orquestados con Docker Compose. 

## Cómo verificar cada ejercicio

La [`GUIA-PRUEBAS.md`](GUIA-PRUEBAS.md) contiene el paso a paso completo. En resumen:

**Jenkins** — `cd jenkins/` y sigue el README. Hace falta Docker para construir la imagen Jenkins+Gradle (ejercicio 1) y para que Jenkins pueda lanzar contenedores vía Docker-in-Docker (ejercicio 2).

**GitHub Actions** — los workflows van en `.github/workflows/` de un repositorio que contenga las carpetas `hangman-front/` (y `hangman-api/` + `hangman-e2e/e2e/` para los E2E). El CI se activa solo al abrir una PR que toque `hangman-front/`. El CD y el E2E se lanzan a mano desde la pestaña Actions (el E2E además tiene un cron diario).


## Notas de implementación

Todo el contenido de GitHub Actions está verificado contra el código real del `.start-code/hangman-front` y `hangman-api` del bootcamp: el front es React+TS con webpack (salida en `dist/`), los tests son Jest, y la `API_URL` se inyecta en runtime vía `entry-point.sh`. El Dockerfile del entregable reproduce el del repo (necesita `nginx.conf` y `entry-point.sh` en el contexto de build).
