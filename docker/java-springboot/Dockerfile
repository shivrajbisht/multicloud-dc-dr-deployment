# ==============================================================================
# MULTI-STAGE DOCKERFILE: JAVA 21 SPRING BOOT MICROSERVICE
# ==============================================================================
# Features:
#   - Multi-stage build for minimal final image size (~180MB vs 800MB)
#   - Multi-arch support (linux/amd64, linux/arm64)
#   - Non-root dedicated appuser (UID 10001) for security hardening
#   - Dynamic JVM Container Memory & CPU Heap allocation flags
#   - Spring Boot layered jar optimization for fast cached rebuilds
# ==============================================================================

# --- Stage 1: Build & Package ---
FROM maven:3.9.6-eclipse-temurin-21-alpine AS builder
WORKDIR /build

# Copy pom.xml and download dependencies for layer caching
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code and build application jar
COPY src ./src
RUN mvn package -DskipTests -B && \
    java -Djarmode=layertools -jar target/*.jar extract --destination target/extracted

# --- Stage 2: Production Hardened Runtime ---
FROM eclipse-temurin:21-jre-alpine AS runner

# Security hardening: Create non-root user & group
RUN addgroup --system --gid 10001 appgroup && \
    adduser --system --uid 10001 --ingroup appgroup appuser

WORKDIR /app

# Copy extracted Spring Boot layers for optimal caching
COPY --from=builder /build/target/extracted/dependencies/ ./
COPY --from=builder /build/target/extracted/spring-boot-loader/ ./
COPY --from=builder /build/target/extracted/snapshot-dependencies/ ./
COPY --from=builder /build/target/extracted/application/ ./

# Set ownership to non-root user
RUN chown -R appuser:appgroup /app

USER appuser:appgroup

# Dynamic JVM Memory & Spring Profile settings
ENV JAVA_OPTS="-XX:+UseG1GC -XX:MaxRAMPercentage=75.0 -XX:InitialRAMPercentage=50.0 -Djava.security.egd=file:/dev/./urandom"
ENV SPRING_PROFILES_ACTIVE="prod"

EXPOSE 8080

HEALTHCHECK --interval=15s --timeout=3s --start-period=30s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS org.springframework.boot.loader.launch.JarLauncher"]
