# ==============================================================================
# MULTI-STAGE DOCKERFILE: ANGULAR / REACT FRONTEND SPA (NGINX UNPRIVILEGED)
# ==============================================================================

FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build -- --configuration=production || npm run build

FROM nginxinc/nginx-unprivileged:alpine-slim AS runner
COPY --from=builder /app/dist/* /usr/share/nginx/html/

# Security Headers & SPA Routing Config
USER 101
EXPOSE 8080
HEALTHCHECK --interval=15s --timeout=3s CMD wget --spider http://localhost:8080/ || exit 1
CMD ["nginx", "-g", "daemon off;"]
