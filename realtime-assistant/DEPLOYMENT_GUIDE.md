# Deployment Guide for HTML Stub Pages

This guide will help you deploy the HTML stub pages to test your DNS records and Caddy routing for both domains.

## Prerequisites

- Server with Caddy installed
- DNS records pointing to your server IP (✅ Already configured)
- Root/sudo access on the server

## Step 1: Create Directory Structure

On your server, create the directory structure that Caddy expects:

```bash
# Create the web root directory
sudo mkdir -p /var/www/html

# Set proper permissions
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html
```

## Step 2: Upload HTML Files

Upload the HTML files to your server:

```bash
# Copy the HTML files to the server
scp realtime-demo.html user@your-server:/tmp/
scp voice-test.html user@your-server:/tmp/

# On the server, move them to the web directory
sudo mv /tmp/realtime-demo.html /var/www/html/
sudo mv /tmp/voice-test.html /var/www/html/

# Set proper permissions
sudo chown www-data:www-data /var/www/html/*.html
sudo chmod 644 /var/www/html/*.html
```

## Step 3: Update Caddy Configuration

The Caddyfile has been updated to serve HTML files instead of proxying to Docker. Make sure to:

1. Copy the updated `Caddyfile` to your server
2. Reload Caddy configuration

```bash
# Copy the Caddyfile to your server
scp Caddyfile user@your-server:/tmp/

# On the server, update the Caddyfile
sudo cp /tmp/Caddyfile /etc/caddy/Caddyfile

# Test the configuration
sudo caddy validate --config /etc/caddy/Caddyfile

# Reload Caddy
sudo systemctl reload caddy
# OR if using caddy as a service
sudo caddy reload --config /etc/caddy/Caddyfile
```

## Step 4: Verify File Permissions

Ensure the HTML files are accessible:

```bash
# Check file permissions
ls -la /var/www/html/

# Should show:
# -rw-r--r-- 1 www-data www-data 1234 Jan 1 12:00 realtime-demo.html
# -rw-r--r-- 1 www-data www-data 1234 Jan 1 12:00 voice-test.html
```

## Step 5: Test the Setup

### Test from your local machine:
```bash
# Test HTTP
curl -I http://realtime-demo.renovavision.tech
curl -I http://voice-test.renovavision.tech

# Test HTTPS
curl -I https://realtime-demo.renovavision.tech
curl -I https://voice-test.renovavision.tech

# Test content
curl -s https://realtime-demo.renovavision.tech | grep -q "realtime-demo.html" && echo "✅ Content OK" || echo "❌ Content mismatch"
curl -s https://voice-test.renovavision.tech | grep -q "voice-test.html" && echo "✅ Content OK" || echo "❌ Content mismatch"
```

### Test from the server:
```bash
# Test local file serving
curl -I http://localhost/realtime-demo.html
curl -I http://localhost/voice-test.html
```

## Step 6: Troubleshooting

### If content still shows mismatch:

1. **Check Caddy logs:**
   ```bash
   sudo journalctl -u caddy -f
   # OR
   sudo tail -f /var/log/caddy/*.log
   ```

2. **Verify Caddy is using the correct config:**
   ```bash
   sudo caddy config --config /etc/caddy/Caddyfile
   ```

3. **Check if Caddy is running:**
   ```bash
   sudo systemctl status caddy
   ```

4. **Test Caddy configuration:**
   ```bash
   sudo caddy validate --config /etc/caddy/Caddyfile
   ```

### If HTTPS fails for voice-test:

1. **Check SSL certificate:**
   ```bash
   sudo caddy cert-info --config /etc/caddy/Caddyfile
   ```

2. **Force certificate renewal:**
   ```bash
   sudo caddy renew --config /etc/caddy/Caddyfile
   ```

3. **Check Caddy logs for SSL errors:**
   ```bash
   sudo journalctl -u caddy | grep -i ssl
   ```

## Step 7: Revert to Production Configuration

Once testing is complete, you can revert the Caddyfile to proxy to your Docker container:

```bash
# Backup the test configuration
sudo cp /etc/caddy/Caddyfile /etc/caddy/Caddyfile.test

# Restore the production configuration
sudo cp /etc/caddy/Caddyfile.production /etc/caddy/Caddyfile

# Reload Caddy
sudo systemctl reload caddy
```

## File Locations Summary

- **HTML Files**: `/var/www/html/`
- **Caddyfile**: `/etc/caddy/Caddyfile`
- **Caddy Logs**: `/var/log/caddy/` or `journalctl -u caddy`
- **Caddy Service**: `systemctl status caddy`

## Expected Results

After successful deployment:
- ✅ DNS resolution works (already confirmed)
- ✅ HTTP responses work (already confirmed)
- ✅ HTTPS responses work
- ✅ Content shows the correct HTML pages
- ✅ Both domains serve their respective stub pages

## Quick Commands

```bash
# Upload files
scp *.html user@your-server:/tmp/
scp Caddyfile user@your-server:/tmp/

# Deploy on server
sudo mkdir -p /var/www/html
sudo mv /tmp/*.html /var/www/html/
sudo cp /tmp/Caddyfile /etc/caddy/
sudo systemctl reload caddy

# Test
curl -s https://realtime-demo.renovavision.tech | grep "realtime-demo.html"
curl -s https://voice-test.renovavision.tech | grep "voice-test.html"
```
