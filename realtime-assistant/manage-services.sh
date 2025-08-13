#!/bin/bash

# Service management script for Traefik
# This script helps manage multiple services with different subdomains

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  list                    List all running services"
    echo "  status                  Show status of all services"
    echo "  logs [SERVICE]          Show logs for a specific service or all"
    echo "  restart [SERVICE]       Restart a specific service or all"
    echo "  stop [SERVICE]          Stop a specific service or all"
    echo "  start [SERVICE]         Start a specific service or all"
    echo "  add-service [NAME] [DOMAIN] [PORT]  Add a new service"
    echo "  remove-service [NAME]   Remove a service"
    echo "  help                    Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 list"
    echo "  $0 status"
    echo "  $0 logs traefik"
    echo "  $0 restart realtime-assistant"
    echo "  $0 add-service blog blog.renovavision.tech 8080"
}

# Function to list services
list_services() {
    print_info "Listing all services..."
    echo ""
    
    # List Traefik services
    if docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -q "traefik"; then
        echo "🌐 Traefik Services:"
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(traefik|realtime-assistant)"
        echo ""
    else
        print_warning "No Traefik services running"
    fi
    
    # List all containers
    echo "🐳 All Running Containers:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
}

# Function to show service status
show_status() {
    print_info "Checking service status..."
    echo ""
    
    # Check Traefik
    if docker ps --format "{{.Names}}" | grep -q "traefik"; then
        print_status "Traefik: Running"
    else
        print_error "Traefik: Not running"
    fi
    
    # Check realtime-assistant
    if docker ps --format "{{.Names}}" | grep -q "realtime-assistant"; then
        print_status "Realtime Assistant: Running"
    else
        print_error "Realtime Assistant: Not running"
    fi
    
    # Check networks
    echo ""
    print_info "Network Status:"
    if docker network ls | grep -q "proxy"; then
        print_status "Proxy network: Available"
    else
        print_error "Proxy network: Not available"
    fi
    
    if docker network ls | grep -q "app-network"; then
        print_status "App network: Available"
    else
        print_error "App network: Not available"
    fi
}

# Function to show logs
show_logs() {
    local service=${1:-"all"}
    
    if [ "$service" = "all" ]; then
        print_info "Showing logs for all services..."
        docker compose -f docker-compose.production.yml logs -f
    else
        print_info "Showing logs for $service..."
        docker compose -f docker-compose.production.yml logs -f "$service"
    fi
}

# Function to restart services
restart_service() {
    local service=${1:-"all"}
    
    if [ "$service" = "all" ]; then
        print_info "Restarting all services..."
        docker compose -f docker-compose.production.yml restart
    else
        print_info "Restarting $service..."
        docker compose -f docker-compose.production.yml restart "$service"
    fi
    
    print_status "Restart completed"
}

# Function to stop services
stop_service() {
    local service=${1:-"all"}
    
    if [ "$service" = "all" ]; then
        print_info "Stopping all services..."
        docker compose -f docker-compose.production.yml down
    else
        print_info "Stopping $service..."
        docker compose -f docker-compose.production.yml stop "$service"
    fi
    
    print_status "Stop completed"
}

# Function to start services
start_service() {
    local service=${1:-"all"}
    
    if [ "$service" = "all" ]; then
        print_info "Starting all services..."
        docker compose -f docker-compose.production.yml up -d
    else
        print_info "Starting $service..."
        docker compose -f docker-compose.production.yml up -d "$service"
    fi
    
    print_status "Start completed"
}

# Function to add a new service
add_service() {
    local name=$1
    local domain=$2
    local port=$3
    
    if [ -z "$name" ] || [ -z "$domain" ] || [ -z "$port" ]; then
        print_error "Usage: $0 add-service [NAME] [DOMAIN] [PORT]"
        echo "Example: $0 add-service blog blog.renovavision.tech 8080"
        exit 1
    fi
    
    print_info "Adding new service: $name"
    print_info "Domain: $domain"
    print_info "Port: $port"
    
    # Create service template
    cat > "docker-compose.${name}.yml" << EOF
version: '3.8'

services:
  ${name}:
    image: nginx:alpine  # Default image, change as needed
    container_name: ${name}
    restart: unless-stopped
    networks:
      - app-network
    expose:
      - "${port}"
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.${name}.rule=Host(\`${domain}\`)"
      - "traefik.http.routers.${name}.entrypoints=websecure"
      - "traefik.http.routers.${name}.tls=true"
      - "traefik.http.routers.${name}.tls.certresolver=le"
      - "traefik.http.services.${name}.loadbalancer.server.port=${port}"

networks:
  app-network:
    external: true
EOF
    
    print_status "Service template created: docker-compose.${name}.yml"
    print_info "Edit the file to customize the service, then run:"
    echo "  docker compose -f docker-compose.production.yml -f docker-compose.${name}.yml up -d ${name}"
}

# Function to remove a service
remove_service() {
    local name=$1
    
    if [ -z "$name" ]; then
        print_error "Usage: $0 remove-service [NAME]"
        exit 1
    fi
    
    print_info "Removing service: $name"
    
    # Stop and remove the service
    docker compose -f "docker-compose.${name}.yml" down 2>/dev/null || true
    
    # Remove the compose file
    if [ -f "docker-compose.${name}.yml" ]; then
        rm "docker-compose.${name}.yml"
        print_status "Service compose file removed"
    else
        print_warning "Service compose file not found"
    fi
    
    print_status "Service removal completed"
}

# Main script logic
case "${1:-help}" in
    "list")
        list_services
        ;;
    "status")
        show_status
        ;;
    "logs")
        show_logs "$2"
        ;;
    "restart")
        restart_service "$2"
        ;;
    "stop")
        stop_service "$2"
        ;;
    "start")
        start_service "$2"
        ;;
    "add-service")
        add_service "$2" "$3" "$4"
        ;;
    "remove-service")
        remove_service "$2"
        ;;
    "help"|*)
        show_usage
        ;;
esac
