# Traefik Configuration

This folder contains the Traefik reverse proxy configuration separated from the main application.

## Files

- `docker-compose.yml` - Traefik service configuration
- `traefik.yml` - Main Traefik configuration file
- `dynamic.yml` - Dynamic configuration for middlewares and TLS options
- `start-traefik.sh` - Script to start Traefik service
- `stop-traefik.sh` - Script to stop Traefik service

## Usage

### Starting Traefik

```bash
cd traefik
./start-traefik.sh
```

### Stopping Traefik

```bash
cd traefik
./stop-traefik.sh
```

### Manual start/stop

```bash
cd traefik
docker compose up -d    # Start
docker compose down     # Stop
docker compose logs -f  # View logs
```

## Configuration

### Environment Variables

Make sure your `.env` file in the parent directory contains:

```bash
ACME_EMAIL=your-email@renovavision.tech
```

### Network

Traefik requires an external network called `traefik`. The start script will create this automatically.

### Ports

- `80` - HTTP (redirects to HTTPS)
- `443` - HTTPS
- `8080` - Traefik dashboard (optional)

### SSL Certificates

Traefik automatically obtains SSL certificates from Let's Encrypt using HTTP challenge validation.

## Integration

The main application (`docker-compose.prod.yml`) depends on Traefik being running first. The deployment script handles this automatically.

## Troubleshooting

1. **Check Traefik logs:**
   ```bash
   cd traefik
   docker compose logs -f
   ```

2. **Check network:**
   ```bash
   docker network ls | grep traefik
   ```

3. **Restart Traefik:**
   ```bash
   cd traefik
   docker compose restart
   ```

4. **View Traefik dashboard:**
   - Local: http://localhost:8080
   - Production: https://traefik.renovavision.tech
