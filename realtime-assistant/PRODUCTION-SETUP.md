# Production Setup with Traefik

This document explains how to deploy your realtime-assistant application to production using Traefik as a reverse proxy with automatic SSL certificates.

## Overview

The production setup includes:
- **Traefik** as a reverse proxy with automatic SSL certificates via Let's Encrypt
- **Automatic HTTPS redirect** for all traffic
- **Subdomain routing** for multiple applications
- **Security headers** and CORS configuration
- **Health checks** and monitoring

## Quick Start

1. **Copy and configure environment variables:**
   ```bash
   cp .env.template .env
   # Edit .env with your actual values
   ```

2. **Update email in Traefik config:**
   Edit `traefik/traefik.yml` and replace `your-email@renovavision.tech` with your actual email.

3. **Set up DNS records:**
   Point these domains to your server's IP:
   - `realtime-demo.renovavision.tech`
   - `traefik.renovavision.tech`
   - `*.renovavision.tech` (wildcard for future subdomains)

4. **Deploy:**
   ```bash
   ./deploy-production.sh
   ```

## DNS Configuration

Configure these DNS A records in your domain registrar:

| Record Type | Name | Value |
|-------------|------|-------|
| A | realtime-demo | YOUR_SERVER_IP |
| A | traefik | YOUR_SERVER_IP |
| A | * | YOUR_SERVER_IP |

## Accessing Services

After deployment, your services will be available at:

- **Realtime Assistant**: https://realtime-demo.renovavision.tech
- **Traefik Dashboard**: https://traefik.renovavision.tech

## Adding New Applications

To add a new application (e.g., `app1.renovavision.tech`):

1. Add your service to `docker-compose.prod.yml`:
   ```yaml
   your-new-app:
     image: your-app-image
     restart: unless-stopped
     labels:
       - "traefik.enable=true"
       - "traefik.http.routers.your-new-app.rule=Host(`app1.renovavision.tech`)"
       - "traefik.http.routers.your-new-app.entrypoints=websecure"
       - "traefik.http.routers.your-new-app.tls.certresolver=letsencrypt"
       - "traefik.http.services.your-new-app.loadbalancer.server.port=8080"
     networks:
       - traefik
   ```

2. Redeploy:
   ```bash
   ./deploy-production.sh
   ```

## Monitoring

### View logs:
```bash
# All services
docker-compose -f docker-compose.prod.yml logs -f

# Specific service
docker-compose -f docker-compose.prod.yml logs -f realtime-assistant
docker-compose -f docker-compose.prod.yml logs -f traefik
```

### Check service status:
```bash
docker-compose -f docker-compose.prod.yml ps
```

### Check SSL certificates:
```bash
# Check certificate info
openssl s_client -connect realtime-demo.renovavision.tech:443 -servername realtime-demo.renovavision.tech < /dev/null

# Check certificate expiry
curl -vI https://realtime-demo.renovavision.tech 2>&1 | grep -i expire
```

## Security Features

- **Automatic HTTPS**: All HTTP traffic redirected to HTTPS
- **Let's Encrypt SSL**: Automatic SSL certificate generation and renewal
- **Security Headers**: HSTS, XSS protection, content type sniffing protection
- **CORS Configuration**: Proper CORS headers for your domains
- **TLS Configuration**: Modern TLS protocols and cipher suites

## Troubleshooting

### SSL Certificate Issues:
1. Check that your DNS records are correct
2. Ensure ports 80 and 443 are open on your server
3. Check Traefik logs: `docker-compose -f docker-compose.prod.yml logs traefik`

### Application Not Accessible:
1. Check if the service is running: `docker-compose -f docker-compose.prod.yml ps`
2. Check application logs: `docker-compose -f docker-compose.prod.yml logs realtime-assistant`
3. Verify Traefik routing: Check the Traefik dashboard at https://traefik.renovavision.tech

### Port Conflicts:
If you have other services running on ports 80 or 443, you'll need to stop them first.

## Backup and Maintenance

### Backup Important Files:
- `certs/acme.json` (SSL certificates)
- `.env` (environment variables)
- `docker-compose.prod.yml` (configuration)

### Updates:
```bash
# Pull latest images and restart
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d
```

## Environment Variables

Key environment variables in `.env`:

- `OPENAI_API_KEY`: Your OpenAI API key
- `ACME_EMAIL`: Email for Let's Encrypt certificates
- `CHAINLIT_PUBLIC_URL`: Public URL of your application

## Network Architecture

```
Internet
    ↓
Traefik (ports 80, 443)
    ↓
realtime-assistant (port 8888, internal)
```

Traefik handles:
- SSL termination
- HTTP to HTTPS redirect
- Subdomain routing
- Load balancing (if needed)
- Health checks
