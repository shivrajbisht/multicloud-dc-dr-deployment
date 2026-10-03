# ==============================================================================
# MULTI-STAGE DOCKERFILE: GOLANG 1.22 MICROSERVICE (DISTROLESS HARDENED)
# ==============================================================================

FROM golang:1.22-alpine AS builder
WORKDIR /app
RUN apk add --no-cache git ca-certificates
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o /app/server .

FROM gcr.io/distroless/static-debian12:nonroot AS runner
WORKDIR /app
COPY --from=builder /app/server /app/server
USER nonroot:nonroot
EXPOSE 8080
ENTRYPOINT ["/app/server"]
