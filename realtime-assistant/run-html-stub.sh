#!/bin/bash

echo "🚀 Starting HTML stub container for Caddy testing..."

# Stop any existing containers
echo "Stopping existing containers..."
docker compose -f docker-compose.html.yml down

# Build and start the HTML stub container
echo "Building and starting HTML stub container..."
docker compose -f docker-compose.html.yml up --build -d

# Wait a moment for the container to start
sleep 5

# Check if the container is running
echo "Checking container status..."
docker compose -f docker-compose.html.yml ps

# Test the health endpoint
echo "Testing health endpoint..."
curl -f http://localhost:8888/health

if [ $? -eq 0 ]; then
    echo "✅ HTML stub container is running successfully on port 8888"
    echo "🌐 You can now test Caddy by visiting your domain"
    echo "📝 The container will respond to Caddy's health checks at /health"
else
    echo "❌ Failed to start HTML stub container"
    exit 1
fi
