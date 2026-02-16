#!/usr/bin/env bash
set -euo pipefail

# Build the dev image and run the dev service, test endpoints, then clean up.
PROJECT_NAME=rawscraper_test

echo "Building dev image..."
docker compose build --no-cache --pull --progress=plain server-dev

echo "Starting dev service in background..."
docker compose up -d server-dev

echo "Waiting for service to become ready..."
sleep 4

echo "Checking root endpoint..."
curl -fsS http://localhost:65000/ || { echo 'root check failed'; docker compose down; exit 1; }

echo "Checking /scrape endpoint..."
curl -fsS http://localhost:65000/scrape || { echo '/scrape check failed'; docker compose down; exit 1; }

echo "Smoke tests passed. Cleaning up..."
docker compose down

echo "Done."
