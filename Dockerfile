# syntax=docker/dockerfile:1

# Comments are provided throughout this file to help you get started.
# If you need more help, visit the Dockerfile reference guide at
# https://docs.docker.com/go/dockerfile-reference/

# Want to help us make this template better? Share your feedback here: https://forms.gle/ybq9Krt8jtBL3iCk7

# syntax=docker/dockerfile:1

ARG NODE_VERSION=20
FROM node:${NODE_VERSION}-slim AS base

# Install Python and utilities needed for the scraper
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 python3-pip build-essential ca-certificates curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Create a non-privileged user the app will run under
ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/usr/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    rogerm

# Copy dependency manifests first to leverage layer caching
COPY package*.json ./
COPY requirements.txt ./
COPY python ./python

# Install Python requirements and Node dependencies
RUN pip3 install --no-cache-dir --break-system-packages -r requirements.txt
RUN npm ci --silent

FROM base AS builder
ENV NODE_ENV=production
RUN npm install --no-audit --silent
COPY . .
RUN npm run build

FROM base AS dev
ENV NODE_ENV=development
RUN npm install --no-audit --silent
COPY . .
EXPOSE 65000
USER rogerm
CMD ["npm","run","dev"]

FROM base AS prod
ENV NODE_ENV=production
COPY --from=builder /app/dist ./dist
COPY python ./python
COPY requirements.txt ./
RUN npm prune --production --silent || true
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:65000/ || exit 1
EXPOSE 65000
USER rogerm
CMD ["npm","start"]
