Title: Realtime Assistant
Tags: [multimodal, audio]

# Open AI realtime API with Chainlit

This cookbook demonstrates how to build realtime copilots with Chainlit.

## Key Features

- **Realtime Python Client**: Based off https://github.com/openai/openai-realtime-api-beta
- **Multimodal experience**: Speak and write to the assistant at the same time
- **Tool calling**: Ask the assistant to perform tasks and see their output in the UI
- **Visual Presence**: Visual cues indicating if the assistant is listening or speaking

## Quick Start

### Development
1. Set your `OPENAI_API_KEY` in the `.env` file
2. Run with Docker: `./run-docker.sh`
3. Or use Docker Compose: `docker compose up --build`

### Production with Traefik
1. Set your `OPENAI_API_KEY` in the `.env` file
2. Setup Traefik network: `./setup-traefik-network.sh`
3. Deploy: `./deploy-production.sh`

## Production Deployment

This project uses **Traefik** as a reverse proxy with automatic SSL certificates from Let's Encrypt.

### Features
- **Automatic HTTPS**: SSL certificates automatically generated and renewed
- **Subdomain Support**: Each service gets its own subdomain (e.g., `realtime-demo.renovavision.tech`)
- **Load Balancing**: Built-in load balancing and health checks
- **Dashboard**: Optional Traefik dashboard for monitoring

### Current Services
- **Realtime Assistant**: `https://realtime-demo.renovavision.tech`
- **Traefik Dashboard**: `https://traefik.renovavision.tech` (optional)

### Adding New Services

Use the service management script to easily add new services:

```bash
# Add a new service
./manage-services.sh add-service blog blog.renovavision.tech 8080

# Deploy the new service
docker compose -f docker-compose.production.yml -f docker-compose.blog.yml up -d blog

# List all services
./manage-services.sh list

# Check service status
./manage-services.sh status
```

### Service Management

```bash
# View logs
./manage-services.sh logs [service-name]

# Restart services
./manage-services.sh restart [service-name]

# Stop/Start services
./manage-services.sh stop [service-name]
./manage-services.sh start [service-name]
```

## Architecture

```
Internet → Traefik (Port 80/443) → Services (Internal Network)
                ↓
        - realtime-demo.renovavision.tech → realtime-assistant:8888
        - blog.renovavision.tech → blog:8080
        - api.renovavision.tech → api:3000
        - etc...
```

## Prerequisites

- Docker and Docker Compose
- Domain pointing to your server
- Ports 80 and 443 open on your firewall
- DNS records configured for subdomains

## Troubleshooting

### Check Service Status
```bash
./manage-services.sh status
```

### View Logs
```bash
./manage-services.sh logs traefik
./manage-services.sh logs realtime-assistant
```

### Network Issues
```bash
# Recreate Traefik network
docker network rm proxy
./setup-traefik-network.sh
```

### SSL Certificate Issues
- Ensure ports 80 and 443 are open
- Check DNS records are pointing to your server
- Verify domain ownership
- Check Traefik logs for ACME challenge errors
