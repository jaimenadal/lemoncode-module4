# Módulo 4 — CI/CD

Entregable del **Bootcamp DevOps Lemoncode**. Pipelines con Jenkins (declarativo) y workflows con GitHub Actions, sobre un proyecto Java + Gradle y sobre el frontend del juego Hangman.

```
lemoncode_module4/
├── README.md                         ← estás aquí
├── jenkins/
│   ├── README.md                     ← instrucciones para levantar Jenkins y correr los pipelines
│   ├── 01-pipeline-basica/
│   │   └── Jenkinsfile               ← Ejercicio 1: agent any, Gradle en la imagen Jenkins
│   └── 02-pipeline-docker-runner/
│       └── Jenkinsfile               ← Ejercicio 2: agent docker con gradle:6.6.1-jre14-openj9
└── github-actions/
    ├── README.md                     ← cómo lanzar cada workflow
    ├── .github/workflows/
    │   ├── ci-hangman-front.yml      ← CI obligatorio (PR + paths)
    │   ├── cd-hangman-front.yml      ← CD obligatorio (manual, push a GHCR)
    │   └── e2e-hangman.yml           ← Opcional 3: E2E con Cypress + docker compose
    ├── hangman-front/
    │   └── Dockerfile                ← multi-stage, nginx no-root, puerto 8080
    └── hangman-e2e/
        └── docker-compose.e2e.yml    ← stack front+api para los tests E2E
```

## Resumen de lo entregado

**Jenkins** — los dos ejercicios obligatorios. El primero usa la imagen Jenkins con Gradle ya instalado (la del `gradle.Dockerfile` que da el bootcamp). El segundo descarga el runner como contenedor efímero por cada build, lo que evita tener que pre-instalar nada en el host Jenkins.

**GitHub Actions** — los dos obligatorios (CI + CD del frontend) y uno de los dos opcionales: los **tests E2E con Cypress** orquestados con Docker Compose. He elegido el opcional 3 frente a la custom JS Action porque levantar un stack completo en pipeline y verificar que funciona extremo a extremo es exactamente lo que se hace en un equipo DevOps real — la JS Action es interesante pero queda en un nicho.

## Cómo verificar cada ejercicio

Cada subcarpeta tiene su propio README con instrucciones detalladas. En resumen:

**Jenkins** — `cd jenkins/` y sigue el README. Hace falta tener Docker para construir la imagen Jenkins+Gradle (ejercicio 1) y para que Jenkins pueda lanzar contenedores via Docker-in-Docker (ejercicio 2).

**GitHub Actions** — los workflows están listos para copiarse a `.github/workflows/` de cualquier repositorio que contenga las carpetas `hangman-front/` (y `hangman-api/` + `hangman-e2e/e2e/` si quieres lanzar los E2E). El workflow CI se activa solo al abrir una PR que toque ese directorio. El CD y el E2E se lanzan a mano desde la pestaña Actions.

## Convenciones aplicadas

- **Pipeline as Code**: ningún job configurado por UI. Todo en Git, revisable por PR.
- **Pin de versiones**: `ubuntu-24.04`, no `ubuntu-latest`. Acciones con `@v4`/`@v5`/`@v6`. Imágenes Docker con tag explícito.
- **Permisos mínimos**: `permissions: contents: read` por defecto, se amplía solo donde hace falta (`packages: write` en el CD).
- **Concurrencia controlada**: builds nuevos en el mismo PR cancelan los previos.
- **Cache de dependencias**: npm cache en CI, layers de Docker en CD, volumen `gradle-cache` en Jenkins.
- **Comentarios dentro del código**: cada decisión no obvia explicada donde vive, no en un README aparte.

## Notas de implementación

Todo el contenido de GitHub Actions está verificado contra el código real del `.start-code/hangman-front` y `hangman-api` del bootcamp: el front es React+TS con webpack (salida en `dist/`), los tests son Jest, y la `API_URL` se inyecta en runtime vía `entry-point.sh`. El Dockerfile del entregable reproduce el del repo (necesita `nginx.conf` y `entry-point.sh` en el contexto de build).

## Captura de pruebas

Las capturas de los pipelines verdes (Jenkins) y los workflows con estado success (GitHub Actions) van en `docs/` cuando se ejecute el entregable real.

---

> 千里の道も一歩から — *El camino de mil millas comienza con un solo paso.*
