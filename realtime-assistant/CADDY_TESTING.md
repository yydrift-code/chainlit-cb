# Caddy Testing with HTML Stub Page

This directory contains a simple HTML stub page setup to test if Caddy reverse proxy is working correctly.

## What This Does

Instead of running the full Chainlit application, this setup serves a simple HTML page from a Docker container on port 8888. This allows you to:

1. **Test Caddy Configuration**: Verify that Caddy can successfully proxy requests to your Docker container
2. **Isolate Issues**: Determine if problems are with Caddy or the application itself
3. **Quick Validation**: Get immediate feedback that your infrastructure is working

## Files Created

- `index.html` - Simple HTML test page with status information
- `Dockerfile.html` - Dockerfile using nginx to serve the HTML page
- `docker-compose.html.yml` - Docker Compose configuration for the HTML stub
- `run-html-stub.sh` - Script to easily start the HTML stub container

## How to Use

### Option 1: Use the Script (Recommended)
```bash
./run-html-stub.sh
```

### Option 2: Manual Docker Commands
```bash
# Build and start the container
docker-compose -f docker-compose.html.yml up --build -d

# Check status
docker-compose -f docker-compose.html.yml ps

# View logs
docker-compose -f docker-compose.html.yml logs -f
```

## What to Expect

1. **Container Status**: The container should start successfully and show as "healthy"
2. **Health Check**: `curl http://localhost:8888/health` should return "healthy"
3. **Web Page**: Visiting `http://localhost:8888` should show the test page
4. **Caddy Proxy**: Your domain should now serve the HTML test page through Caddy

## Testing Caddy

Once the HTML stub is running:

1. **Local Test**: Visit `http://localhost:8888` to see the test page
2. **Caddy Test**: Visit your domain (e.g., `https://realtime-demo.renovavision.tech`) to see if Caddy is proxying correctly
3. **Health Check**: Caddy should be able to reach the `/health` endpoint

## Troubleshooting

### Container Won't Start
- Check if port 8888 is already in use
- Ensure Docker is running
- Check Docker logs: `docker-compose -f docker-compose.html.yml logs`

### Health Check Fails
- Verify the container is running: `docker ps`
- Check nginx logs inside container: `docker exec -it <container_id> nginx -t`

### Caddy Can't Reach Container
- Ensure the container is running on port 8888
- Check if there are firewall rules blocking localhost:8888
- Verify Caddy configuration points to `localhost:8888`

## Switching Back to Chainlit

When you're ready to test the actual application:

```bash
# Stop the HTML stub
docker-compose -f docker-compose.html.yml down

# Start the original Chainlit app
docker-compose up --build -d
```

## Benefits of This Approach

- **Lightweight**: Uses minimal resources compared to full Chainlit app
- **Fast**: Quick startup and response times
- **Reliable**: Simple nginx server is very stable
- **Debuggable**: Easy to isolate whether issues are with Caddy or the application
- **Health Check Compatible**: Includes the same health endpoint that Caddy expects
