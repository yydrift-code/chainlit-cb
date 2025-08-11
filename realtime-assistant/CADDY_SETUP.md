# Caddy Reverse Proxy Setup for Production

This document explains how to deploy your realtime assistant with Caddy reverse proxy for production use.

## 🎯 **Target Configuration**

- **Subdomain**: `realtime-demo.renovavision.tech`
- **Backend**: Docker container running on port 8888
- **Proxy**: Caddy with automatic HTTPS

## 📁 **Files Created**

1. **`Caddyfile`** - Main Caddy configuration
2. **`docker-compose.production.yml`** - Production Docker stack
3. **`deploy-production.sh`** - Deployment script
4. **`health.py`** - Health check endpoint (optional)

## 🚀 **Quick Deployment**

### Prerequisites
- Docker and Docker Compose installed
- Domain `renovavision.tech` pointing to your server
- Ports 80 and 443 open on your server
- `.env` file with `OPENAI_API_KEY`

### Deploy
```bash
# Make script executable
chmod +x deploy-production.sh

# Run deployment
./deploy-production.sh
```

## 🔧 **Manual Setup**

### 1. Start the production stack
```bash
docker compose -f docker-compose.production.yml up -d
```

### 2. Check status
```bash
docker compose -f docker-compose.production.yml ps
```

### 3. View logs
```bash
docker compose -f docker-compose.production.yml logs -f
```

## 🌐 **DNS Configuration**

Before deploying, ensure your DNS records are configured:

```
Type: A
Name: realtime-demo
Value: [YOUR_SERVER_IP]

Type: AAAA (if using IPv6)
Name: realtime-demo  
Value: [YOUR_SERVER_IPV6]
```

## 🔒 **Security Features**

Caddy automatically provides:
- ✅ **SSL/TLS certificates** from Let's Encrypt
- ✅ **HTTP/2 and HTTP/3** support
- ✅ **Security headers** (XSS protection, content type options)
- ✅ **Health checks** for backend monitoring
- ✅ **WebSocket support** for realtime features

## 📊 **Monitoring**

### Health Check Endpoints
- `/health` - Detailed health metrics
- `/health/simple` - Basic status check

### Logs
- **Caddy logs**: `/var/log/caddy/realtime-demo.log`
- **Container logs**: `docker compose -f docker-compose.production.yml logs`

## 🔄 **Updating**

### Redeploy after changes
```bash
./deploy-production.sh
```

### Manual update
```bash
docker compose -f docker-compose.production.yml down
docker compose -f docker-compose.production.yml up --build -d
```

## 🐛 **Troubleshooting**

### Check Caddy status
```bash
docker compose -f docker-compose.production.yml exec caddy caddy version
```

### Test backend connectivity
```bash
curl http://localhost:8888/health
```

### View Caddy configuration
```bash
docker compose -f docker-compose.production.yml exec caddy caddy config
```

### Check SSL certificate
```bash
openssl s_client -connect realtime-demo.renovavision.tech:443 -servername realtime-demo.renovavision.tech
```

## 📚 **Caddy Features Used**

- **Reverse Proxy**: Routes traffic to your app
- **Automatic HTTPS**: Let's Encrypt integration
- **Health Checks**: Monitors backend availability
- **Load Balancing**: Ready for multiple backends
- **WebSocket Support**: Essential for realtime features
- **Security Headers**: Protection against common attacks
- **Logging**: JSON-formatted access logs

## 🔧 **Customization**

### Modify Caddyfile
Edit `Caddyfile` to:
- Add more subdomains
- Configure additional security headers
- Set up rate limiting
- Add authentication

### Environment Variables
Set in `.env`:
```bash
OPENAI_API_KEY=your_key_here
CHAINLIT_HOST=0.0.0.0
CHAINLIT_PORT=8888
```

## 📞 **Support**

For Caddy-specific issues:
- [Caddy Documentation](https://caddyserver.com/docs/)
- [Caddy Community](https://caddy.community/)

For your app issues:
- Check container logs
- Verify environment variables
- Test backend connectivity
