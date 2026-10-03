# ==============================================================================
# MULTI-ARCH DOCKERFILE FOR NODE.JS APPLICATION
# Compatible Architectures: linux/amd64, linux/arm64
# Multi-Stage Build: Dependencies -> Build -> Production Alpine Runtime Stage
# ==============================================================================

# ------------------------------------------------------------------------------
# STAGE 1: Dependencies Installation
# ------------------------------------------------------------------------------
FROM node:20-alpine AS deps

# Install libc6-compat for native node modules compatibility on Alpine
RUN apk add --no-cache libc6-compat

WORKDIR /app

# Copy package manifests first for optimal layer caching
COPY package.json package-lock.json ./

# Clean install node dependencies (production & dev dependencies for build)
RUN npm ci

# ------------------------------------------------------------------------------
# STAGE 2: Build Stage (Typescript compilation / bundling if applicable)
# ------------------------------------------------------------------------------
FROM node:20-alpine AS builder

WORKDIR /app

# Copy node modules from deps stage
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Environment production flag
ENV NODE_ENV=production

# Run build script (transpiling TypeScript or bundling JS if configured)
RUN npm run build --if-present && \
    # Prune devDependencies to keep image footprint minimal
    npm prune --production

# ------------------------------------------------------------------------------
# STAGE 3: Production Runtime Environment (Multi-Arch Target)
# ------------------------------------------------------------------------------
FROM node:20-alpine AS runner

WORKDIR /app

# Set NODE_ENV to production
ENV NODE_ENV=production
ENV PORT=3000

# Create non-privileged system user for container security
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nodejsuser

# Copy application artifacts and node_modules from builder
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist

# Change file ownership to non-root user
RUN chown -R nodejsuser:nodejs /app

# Switch to non-root user
USER nodejsuser

# Expose container application port
EXPOSE 3000

# Health check command using standard node execution or HTTP endpoint check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Launch Node.js application server
CMD ["node", "dist/index.js"]
