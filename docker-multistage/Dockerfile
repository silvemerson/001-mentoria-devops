# Etapa 1: Builder
FROM alpine AS builder
WORKDIR /app
COPY index.html .

# Etapa 2: Nginx
FROM cgr.dev/chainguard/nginx:latest
EXPOSE 80
COPY --from=builder /app/index.html /usr/share/nginx/html/index.html