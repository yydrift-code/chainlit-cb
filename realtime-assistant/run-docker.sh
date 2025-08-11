#!/bin/bash

# Check if OPENAI_API_KEY is set
if [ -z "$OPENAI_API_KEY" ]; then
    echo "Error: OPENAI_API_KEY environment variable is not set"
    echo "Please set it with: export OPENAI_API_KEY=your_api_key_here"
    exit 1
fi

# Build the Docker image
echo "Building Docker image..."
docker build -t realtime-assistant .

# Run the container
echo "Starting realtime assistant container..."
docker run -d \
    --name realtime-assistant \
    -p 8888:8888 \
    -e OPENAI_API_KEY="$OPENAI_API_KEY" \
    --restart unless-stopped \
    realtime-assistant

echo "Container started! Access the app at http://localhost:8888"
echo "To view logs: docker logs -f realtime-assistant"
echo "To stop: docker stop realtime-assistant"
echo "To remove: docker rm realtime-assistant" 