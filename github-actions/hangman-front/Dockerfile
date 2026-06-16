# ═══════════════════════════════════════════════════════════════════════════
# Dockerfile — hangman-front
# ═══════════════════════════════════════════════════════════════════════════

# ─── Stage 1: build ────────────────────────────────────────────────────────
FROM node:lts-alpine AS build

WORKDIR /opt/build

# Placeholder que entry-point.sh reemplazará en runtime. NO pongas aquí la URL
# real: el valor efectivo se inyecta al arrancar el contenedor, no al construir.
ARG API_URL={{API_URL}}

# Copiamos primero los manifests para cachear `npm ci` mientras no cambien deps
COPY *.json ./
COPY .babelrc .
RUN npm ci

# Ahora el código y la config de webpack
COPY ./src ./src
COPY ./config ./config

RUN npm run build

# ─── Stage 2: runtime ──────────────────────────────────────────────────────
FROM nginx:1.19.0-alpine AS app

# nginx.conf del repo: escucha en :8080 y hace try_files → /index.html
# (fallback SPA, necesario para que el routing del front no devuelva 404).
COPY nginx.conf /etc/nginx/nginx.conf

WORKDIR /usr/share/nginx/html
COPY --from=build /opt/build/dist/ .

EXPOSE 8080

# entry-point.sh sustituye {{API_URL}} por $API_URL y luego ejecuta el CMD
COPY ./entry-point.sh /
RUN chmod +x /entry-point.sh
ENTRYPOINT [ "sh", "/entry-point.sh" ]
CMD [ "nginx", "-g", "daemon off;" ]
