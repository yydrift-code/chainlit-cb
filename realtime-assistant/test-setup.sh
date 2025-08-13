#!/bin/bash

# Test script for DNS records and Caddy routing
# This script helps verify that both domains are properly configured

echo "🌐 Testing DNS Records and Caddy Routing"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to test DNS resolution
test_dns() {
    local domain=$1
    echo -e "${BLUE}Testing DNS resolution for: ${domain}${NC}"
    
    # Check if domain resolves
    if nslookup $domain > /dev/null 2>&1; then
        echo -e "  ${GREEN}✅ DNS resolution: SUCCESS${NC}"
        
        # Get IP address
        local ip=$(nslookup $domain | grep -A1 "Name:" | tail -1 | awk '{print $2}')
        if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo -e "  ${GREEN}  IP Address: ${ip}${NC}"
        else
            echo -e "  ${YELLOW}  IP Address: Could not determine${NC}"
        fi
    else
        echo -e "  ${RED}❌ DNS resolution: FAILED${NC}"
    fi
    
    echo ""
}

# Function to test HTTP response
test_http() {
    local domain=$1
    local expected_file=$2
    
    echo -e "${BLUE}Testing HTTP response for: ${domain}${NC}"
    
    # Test HTTP response
    if curl -s -I "http://${domain}" > /dev/null 2>&1; then
        echo -e "  ${GREEN}✅ HTTP response: SUCCESS${NC}"
        
        # Check if the response contains expected content
        if curl -s "http://${domain}" | grep -q "$expected_file"; then
            echo -e "  ${GREEN}✅ Content verification: SUCCESS${NC}"
        else
            echo -e "  ${YELLOW}⚠️  Content verification: Content mismatch${NC}"
        fi
    else
        echo -e "  ${RED}❌ HTTP response: FAILED${NC}"
    fi
    
    echo ""
}

# Function to test HTTPS response
test_https() {
    local domain=$1
    local expected_file=$2
    
    echo -e "${BLUE}Testing HTTPS response for: ${domain}${NC}"
    
    # Test HTTPS response
    if curl -s -I "https://${domain}" > /dev/null 2>&1; then
        echo -e "  ${GREEN}✅ HTTPS response: SUCCESS${NC}"
        
        # Check if the response contains expected content
        if curl -s "https://${domain}" | grep -q "$expected_file"; then
            echo -e "  ${GREEN}✅ Content verification: SUCCESS${NC}"
        else
            echo -e "  ${YELLOW}⚠️  Content verification: Content mismatch${NC}"
        fi
    else
        echo -e "  ${RED}❌ HTTPS response: FAILED${NC}"
    fi
    
    echo ""
}

# Test both domains
echo -e "${YELLOW}Testing realtime-demo.renovavision.tech${NC}"
test_dns "realtime-demo.renovavision.tech"
test_http "realtime-demo.renovavision.tech" "realtime-demo.html"
test_https "realtime-demo.renovavision.tech" "realtime-demo.html"

echo -e "${YELLOW}Testing voice-test.renovavision.tech${NC}"
test_dns "voice-test.renovavision.tech"
test_http "voice-test.renovavision.tech" "voice-test.html"
test_https "voice-test.renovavision.tech" "voice-test.html"

echo "========================================"
echo -e "${GREEN}Testing completed!${NC}"
echo ""
echo "Next steps:"
echo "1. Ensure your DNS records point to your server IP"
echo "2. Make sure Caddy is running with the updated configuration"
echo "3. Place the HTML files in /var/www/html/ on your server"
echo "4. Check Caddy logs for any errors"
echo ""
echo "To test manually, visit:"
echo "- http://realtime-demo.renovavision.tech"
echo "- https://realtime-demo.renovavision.tech"
echo "- http://voice-test.renovavision.tech"
echo "- https://voice-test.renovavision.tech"
