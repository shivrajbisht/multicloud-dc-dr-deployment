# ==============================================================================
# MULTI-STAGE DOCKERFILE: NODE.JS 20 MICROSERVICE
# ==============================================================================

FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build --if-present && npm prune --production

FROM node:20-alpine AS runner
WORKDIR /app
RUN addgroup --system --gid 10001 appgroup && \
    adduser --system --uid 10001 --ingroup appgroup appuser

COPY --chown=appuser:appgroup --from=builder /app/package*.json ./
COPY --chown=appuser:appgroup --from=builder /app/node_modules ./node_modules
COPY --chown=appuser:appgroup --from=builder /app/dist ./dist

USER appuser:appgroup
ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000
HEALTHCHECK --interval=15s --timeout=3s CMD wget --spider http://localhost:3000/health || exit 1

CMD ["node", "dist/main.js"]
