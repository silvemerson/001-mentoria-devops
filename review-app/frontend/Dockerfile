# Build stage
FROM node:20-alpine as builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Runtime stage
FROM node:20-alpine

WORKDIR /app

RUN npm install -g serve

COPY --from=builder /app/dist ./dist

EXPOSE 3000

ENV NEXT_PUBLIC_API_URL=http://backend.review-app.svc.cluster.local:8081

CMD ["serve", "-s", "dist", "-l", "3000"]