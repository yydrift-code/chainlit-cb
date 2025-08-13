#!/bin/bash

# Deployment script for HTML stub pages
# This script automates the deployment process

set -e  # Exit on any error

# Configuration
SERVER_USER="root"  # Change this to your server username
SERVER_IP="104.248.37.226"  # Your server IP
SERVER_PATH="/tmp"
WEB_ROOT="/var/www/html"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Deploying HTML Stub Pages to Server${NC}"
echo "=============================================="
echo ""

# Check if required files exist
if [[ ! -f "realtime-demo.html" ]] || [[ ! -f "voice-test.html" ]] || [[ ! -f "Caddyfile" ]]; then
    echo -e "${RED}❌ Required files not found!${NC}"
    echo "Make sure you have:"
    echo "- realtime-demo.html"
    echo "- voice-test.html" 
    echo "- Caddyfile"
    exit 1
fi

echo -e "${GREEN}✅ All required files found${NC}"
echo ""

# Step 1: Upload files to server
echo -e "${BLUE}📤 Uploading files to server...${NC}"
scp realtime-demo.html "${SERVER_USER}@${SERVER_IP}:${SERVER_PATH}/"
scp voice-test.html "${SERVER_USER}@${SERVER_IP}:${SERVER_PATH}/"
scp Caddyfile "${SERVER_USER}@${SERVER_IP}:${SERVER_PATH}/"
echo -e "${GREEN}✅ Files uploaded successfully${NC}"
echo ""

# Step 2: Deploy on server
echo -e "${BLUE}🔧 Deploying on server...${NC}"
ssh "${SERVER_USER}@${SERVER_IP}" << 'EOF'
    set -e
    
    echo "Creating web directory..."
    sudo mkdir -p /var/www/html
    
    echo "Moving HTML files..."
    sudo mv /tmp/realtime-demo.html /var/www/html/
    sudo mv /tmp/voice-test.html /var/www/html/
    
    echo "Setting permissions..."
    sudo chown -R www-data:www-data /var/www/html
    sudo chmod -R 755 /var/www/html
    sudo chmod 644 /var/www/html/*.html
    
    echo "Detecting Caddy configuration location..."
    
    # Check common Caddy configuration locations
    if [ -d "/etc/caddy" ]; then
        CADDY_CONFIG_DIR="/etc/caddy"
        echo "Found Caddy config at: /etc/caddy"
    elif [ -d "/etc/caddy-server" ]; then
        CADDY_CONFIG_DIR="/etc/caddy-server"
        echo "Found Caddy config at: /etc/caddy-server"
    elif [ -f "/etc/caddy/Caddyfile" ]; then
        CADDY_CONFIG_DIR="/etc/caddy"
        echo "Found Caddy config at: /etc/caddy"
    elif [ -f "/etc/caddy-server/Caddyfile" ]; then
        CADDY_CONFIG_DIR="/etc/caddy-server"
        echo "Found Caddy config at: /etc/caddy-server"
    else
        echo "Caddy config directory not found in common locations"
        echo "Creating /etc/caddy directory..."
        sudo mkdir -p /etc/caddy
        CADDY_CONFIG_DIR="/etc/caddy"
    fi
    
    echo "Updating Caddy configuration at: $CADDY_CONFIG_DIR"
    sudo cp /tmp/Caddyfile "$CADDY_CONFIG_DIR/"
    
    echo "Validating Caddy configuration..."
    sudo caddy validate --config "$CADDY_CONFIG_DIR/Caddyfile"
    
    echo "Reloading Caddy..."
    # Try different reload methods
    if command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet caddy; then
        echo "Using systemctl to reload Caddy..."
        sudo systemctl reload caddy
    elif command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet caddy-server; then
        echo "Using systemctl to reload caddy-server..."
        sudo systemctl reload caddy-server
    else
        echo "Using caddy reload command..."
        sudo caddy reload --config "$CADDY_CONFIG_DIR/Caddyfile"
    fi
    
    echo "Checking Caddy status..."
    if command -v systemctl >/dev/null 2>&1; then
        if systemctl is-active --quiet caddy; then
            sudo systemctl status caddy --no-pager
        elif systemctl is-active --quiet caddy-server; then
            sudo systemctl status caddy-server --no-pager
        else
            echo "Caddy service not found via systemctl"
        fi
    fi
    
    echo "Listing web directory contents..."
    ls -la /var/www/html/
    
    echo "Listing Caddy config directory contents..."
    ls -la "$CADDY_CONFIG_DIR/"
EOF

echo -e "${GREEN}✅ Deployment completed successfully!${NC}"
echo ""

# Step 3: Test the deployment
echo -e "${BLUE}🧪 Testing deployment...${NC}"
echo "Testing realtime-demo.renovavision.tech..."
if curl -s "https://realtime-demo.renovavision.tech" | grep -q "realtime-demo.html"; then
    echo -e "  ${GREEN}✅ Content verification: SUCCESS${NC}"
else
    echo -e "  ${YELLOW}⚠️  Content verification: Content mismatch${NC}"
fi

echo "Testing voice-test.renovavision.tech..."
if curl -s "https://voice-test.renovavision.tech" | grep -q "voice-test.html"; then
    echo -e "  ${GREEN}✅ Content verification: SUCCESS${NC}"
else
    echo -e "  ${YELLOW}⚠️  Content verification: Content mismatch${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Deployment and testing completed!${NC}"
echo ""
echo "Next steps:"
echo "1. Visit https://realtime-demo.renovavision.tech"
echo "2. Visit https://voice-test.renovavision.tech"
echo "3. Verify both domains show the correct HTML pages"
echo ""
echo "To revert to production configuration later:"
echo "sudo cp /etc/caddy/Caddyfile.production /etc/caddy/Caddyfile"
echo "sudo systemctl reload caddy"
