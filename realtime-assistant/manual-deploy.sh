#!/bin/bash

# Manual deployment script for HTML stub pages
# Run this script step by step to deploy and troubleshoot

set -e  # Exit on any error

# Configuration
SERVER_USER="root"  # Change this to your server username
SERVER_IP="104.248.37.226"  # Your server IP

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 Manual Deployment Script for HTML Stub Pages${NC}"
echo "====================================================="
echo ""

echo -e "${YELLOW}This script will help you deploy step by step.${NC}"
echo "Press Enter to continue with each step, or Ctrl+C to exit."
echo ""

# Step 1: Check local files
echo -e "${BLUE}Step 1: Checking local files...${NC}"
if [[ ! -f "realtime-demo.html" ]] || [[ ! -f "voice-test.html" ]] || [[ ! -f "Caddyfile" ]]; then
    echo -e "${RED}❌ Required files not found!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ All required files found${NC}"
read -p "Press Enter to continue..."

# Step 2: Upload files
echo -e "${BLUE}Step 2: Uploading files to server...${NC}"
echo "Uploading realtime-demo.html..."
scp realtime-demo.html "${SERVER_USER}@${SERVER_IP}:/tmp/"
echo "Uploading voice-test.html..."
scp voice-test.html "${SERVER_USER}@${SERVER_IP}:/tmp/"
echo "Uploading Caddyfile..."
scp Caddyfile "${SERVER_USER}@${SERVER_IP}:/tmp/"
echo -e "${GREEN}✅ Files uploaded successfully${NC}"
read -p "Press Enter to continue..."

# Step 3: Connect to server and deploy
echo -e "${BLUE}Step 3: Connecting to server for deployment...${NC}"
echo "You will now be connected to your server."
echo "The following commands will be executed:"
echo ""
echo "1. Create web directory"
echo "2. Move HTML files"
echo "3. Set permissions"
echo "4. Detect Caddy config location"
echo "5. Update Caddy configuration"
echo "6. Reload Caddy"
echo ""
read -p "Press Enter to connect to server..."

ssh "${SERVER_USER}@${SERVER_IP}" << 'EOF'
    set -e
    
    echo "=== Step 1: Creating web directory ==="
    sudo mkdir -p /var/www/html
    echo "✅ Web directory created"
    
    echo ""
    echo "=== Step 2: Moving HTML files ==="
    sudo mv /tmp/realtime-demo.html /var/www/html/
    sudo mv /tmp/voice-test.html /var/www/html/
    echo "✅ HTML files moved"
    
    echo ""
    echo "=== Step 3: Setting permissions ==="
    sudo chown -R www-data:www-data /var/www/html
    sudo chmod -R 755 /var/www/html
    sudo chmod 644 /var/www/html/*.html
    echo "✅ Permissions set"
    
    echo ""
    echo "=== Step 4: Detecting Caddy configuration location ==="
    
    # Check common Caddy configuration locations
    if [ -d "/etc/caddy" ]; then
        CADDY_CONFIG_DIR="/etc/caddy"
        echo "✅ Found Caddy config at: /etc/caddy"
    elif [ -d "/etc/caddy-server" ]; then
        CADDY_CONFIG_DIR="/etc/caddy-server"
        echo "✅ Found Caddy config at: /etc/caddy-server"
    elif [ -f "/etc/caddy/Caddyfile" ]; then
        CADDY_CONFIG_DIR="/etc/caddy"
        echo "✅ Found Caddy config at: /etc/caddy"
    elif [ -f "/etc/caddy-server/Caddyfile" ]; then
        CADDY_CONFIG_DIR="/etc/caddy-server"
        echo "✅ Found Caddy config at: /etc/caddy-server"
    else
        echo "⚠️  Caddy config directory not found in common locations"
        echo "Creating /etc/caddy directory..."
        sudo mkdir -p /etc/caddy
        CADDY_CONFIG_DIR="/etc/caddy"
        echo "✅ Created /etc/caddy directory"
    fi
    
    echo ""
    echo "=== Step 5: Updating Caddy configuration ==="
    echo "Copying Caddyfile to: $CADDY_CONFIG_DIR"
    sudo cp /tmp/Caddyfile "$CADDY_CONFIG_DIR/"
    echo "✅ Caddyfile updated"
    
    echo ""
    echo "=== Step 6: Validating Caddy configuration ==="
    sudo caddy validate --config "$CADDY_CONFIG_DIR/Caddyfile"
    echo "✅ Configuration validated"
    
    echo ""
    echo "=== Step 7: Reloading Caddy ==="
    # Try different reload methods
    if command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet caddy; then
        echo "Using systemctl to reload Caddy..."
        sudo systemctl reload caddy
        echo "✅ Caddy reloaded via systemctl"
    elif command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet caddy-server; then
        echo "Using systemctl to reload caddy-server..."
        sudo systemctl reload caddy-server
        echo "✅ Caddy reloaded via systemctl"
    else
        echo "Using caddy reload command..."
        sudo caddy reload --config "$CADDY_CONFIG_DIR/Caddyfile"
        echo "✅ Caddy reloaded via command"
    fi
    
    echo ""
    echo "=== Step 8: Checking status ==="
    echo "Web directory contents:"
    ls -la /var/www/html/
    
    echo ""
    echo "Caddy config directory contents:"
    ls -la "$CADDY_CONFIG_DIR/"
    
    echo ""
    echo "Caddy service status:"
    if command -v systemctl >/dev/null 2>&1; then
        if systemctl is-active --quiet caddy; then
            sudo systemctl status caddy --no-pager
        elif systemctl is-active --quiet caddy-server; then
            sudo systemctl status caddy-server --no-pager
        else
            echo "Caddy service not found via systemctl"
        fi
    fi
    
    echo ""
    echo "=== Deployment completed! ==="
    echo "You can now test your domains:"
    echo "- https://realtime-demo.renovavision.tech"
    echo "- https://voice-test.renovavision.tech"
EOF

echo ""
echo -e "${GREEN}🎉 Manual deployment completed!${NC}"
echo ""
echo "Next steps:"
echo "1. Test your domains in a browser"
echo "2. Run the test script: ./test-setup.sh"
echo "3. Check for any errors in the output above"
echo ""
echo "If you encounter issues, check:"
echo "- Caddy logs: sudo journalctl -u caddy -f"
echo "- File permissions: ls -la /var/www/html/"
echo "- Caddy status: sudo systemctl status caddy"
