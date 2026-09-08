ARG BUILD_ARCH
ARG BUILD_FROM=ghcr.io/home-assistant/${BUILD_ARCH}-base:latest

FROM $BUILD_FROM AS fetch_source
LABEL io.hass.arch="amd64 aarch64"
RUN apk add --no-cache git
WORKDIR /ne_src
RUN git clone --depth 1 --branch v2.2.3 https://github.com/nxzai/NextExplorer .

RUN sed -i "/export default defineConfig({/a\\  base: './'," frontend/vite.config.js \
 && sed -i "s#const DEFAULT_API_BASE = '/';#const DEFAULT_API_BASE = '.';#" frontend/src/api/http.js \
 && sed -i "s/import { createRouter, createWebHistory } from 'vue-router';/import { createRouter, createWebHashHistory } from 'vue-router';/" frontend/src/router/index.js \
 && sed -i "s#history: createWebHistory(import.meta.env.BASE_URL),#history: createWebHashHistory(),#" frontend/src/router/index.js \
 && find frontend/src backend/src -type f \( -name '*.js' -o -name '*.vue' \) -exec sed -i "s#'/logo.svg'#'./logo.svg'#g" {} +

FROM $BUILD_FROM AS base
WORKDIR /app
RUN apk add --no-cache nodejs npm
RUN apk add --no-cache bash jq

FROM base AS backend_deps
ENV NODE_ENV=production
WORKDIR /app
RUN apk add --no-cache python3 make g++ linux-headers
COPY --from=fetch_source /ne_src/package.json /ne_src/package-lock.json ./
COPY --from=fetch_source /ne_src/backend/package.json backend/package.json
COPY --from=fetch_source /ne_src/frontend/package.json frontend/package.json
COPY --from=fetch_source /ne_src/docs/package.json docs/package.json
RUN npm ci --omit=dev --workspace backend && npm cache clean --force

FROM base AS frontend_build
ENV NODE_ENV=development
WORKDIR /app
COPY --from=fetch_source /ne_src/package.json /ne_src/package-lock.json ./
COPY --from=fetch_source /ne_src/backend/package.json backend/package.json
COPY --from=fetch_source /ne_src/frontend/package.json frontend/package.json
COPY --from=fetch_source /ne_src/docs/package.json docs/package.json
RUN npm ci --workspace frontend
COPY --from=fetch_source /ne_src/frontend/ ./frontend/
RUN npm run -w frontend build -- --sourcemap false

FROM base AS runtime
ENV NODE_ENV=production
ENV CONFIG_DIR=/config
ENV CACHE_DIR=/cache
ENV VOLUME_ROOT=/storage
RUN apk add --no-cache \
      ffmpeg gosu ripgrep imagemagick openssh-client unzip bash shadow perl \
      libva mesa-va-gallium curl autofs cifs-utils \
  && rm -rf /tmp/* /var/cache/apk/*
WORKDIR /app
ARG GIT_COMMIT=""
ARG GIT_BRANCH=""
ARG REPO_URL=""
ENV GIT_COMMIT=${GIT_COMMIT}
ENV GIT_BRANCH=${GIT_BRANCH}
ENV REPO_URL=${REPO_URL}
COPY --from=backend_deps /app/node_modules ./node_modules
COPY --from=backend_deps /app/package.json ./
COPY --from=fetch_source /ne_src/backend/src ./src
COPY --from=fetch_source /ne_src/docker/healthcheck.js ./healthcheck.js
RUN mkdir -p src/public
COPY --from=frontend_build /app/frontend/dist/ ./src/public/
RUN chmod -R a+rX /app/src
COPY rootfs/ /
RUN find /etc -type f \( -name "*.sh" -o -name "run" -o -name "finish" \) -print -exec chmod +x {} \;
