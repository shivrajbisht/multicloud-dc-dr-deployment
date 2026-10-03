# ==============================================================================
# MULTI-ARCH DOCKERFILE FOR JAVA SPRING BOOT APPLICATION
# Compatible Architectures: linux/amd64, linux/arm64
# Multi-Stage Build: Build Stage -> Security Hardened JRE Runtime Stage
# ==============================================================================

# ------------------------------------------------------------------------------
# STAGE 1: Maven Build Environment (Multi-Arch Platform Agnostic)
# ------------------------------------------------------------------------------
FROM --platform=$BUILDPLATFORM maven:3.9.6-eclipse-temurin-21-alpine AS builder

# Set working directory inside container
WORKDIR /app

# Copy Maven dependency POM definition first to leverage Docker layer caching
COPY pom.xml ./

# Pre-fetch all dependencies offline before copying code
RUN mvn dependency:go-offline -B

# Copy full application source code
COPY src ./src

# Build production JAR package skipping test suite execution for build speed
RUN mvn package -DskipTests -B && \
    # Extract Spring Boot jar layers for optimized container caching
    java -Djarmode=layertools -jar target/*.jar extract --destination target/extracted

# ------------------------------------------------------------------------------
# STAGE 2: Security-Hardened JRE 21 Runtime Environment (Multi-Arch Target)
# ------------------------------------------------------------------------------
FROM eclipse-temurin:21-jre-alpine AS runner

# Create non-root system group and user for security compliance
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Set runtime working directory
WORKDIR /app

# Copy extracted Spring Boot application layers from builder stage
COPY --from=builder /app/target/extracted/dependencies/ ./
COPY --from=builder /app/target/extracted/spring-boot-loader/ ./
COPY --from=builder /app/target/extracted/snapshot-dependencies/ ./
COPY --from=builder /app/target/extracted/application/ ./

# Change ownership of app directory to non-root user
RUN chown -R appuser:appgroup /app

# Switch context to non-root user
USER appuser

# Expose HTTP web server port
EXPOSE 8080

# Environment variables for JVM container awareness and memory tuning
ENV JAVA_OPTS="-XX:+UseG1GC -XX:MaxRAMPercentage=75.0 -XX:+ExitOnOutOfMemoryError"

# Container Health Check instruction using wget (available in alpine)
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Entrypoint to execute Spring Boot launcher
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS org.springframework.boot.loader.launch.JarLauncher"]
