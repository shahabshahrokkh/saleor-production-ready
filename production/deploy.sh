#!/bin/bash
# Production deployment script for Linux/Mac
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== Saleor Production Deploy ==="

# Check .env exists
if [ ! -f ".env" ]; then
    echo "ERROR: .env file not found. Copy .env.example to .env and configure it."
    exit 1
fi

# Step 1: Build and start backend
echo ""
echo "[1/3] Building and starting backend..."
docker compose build api worker
docker compose up -d db redis
echo "Waiting for database..."
sleep 5
docker compose up -d api worker

# Step 2: Wait for API
echo ""
echo "[2/3] Waiting for API to be ready..."
for i in $(seq 1 30); do
    if curl -sf http://localhost:8000/graphql/ > /dev/null 2>&1; then
        echo "API is ready!"
        break
    fi
    echo "  Attempt $i/30..."
    sleep 3
done

# Step 3: Build and start storefront
echo ""
echo "[3/3] Building storefront..."
docker compose build storefront
docker compose up -d storefront

echo ""
echo "=== Deployment Complete ==="
echo "  API:        http://localhost:8000/graphql/"
echo "  Storefront: http://localhost:3000"
echo ""
echo "To create admin: docker compose exec api python manage.py createsuperuser"
