#!/bin/bash
# Production Deployment Script for AI-CRM

set -e  # Exit on error

echo "==================================="
echo "AI-CRM Production Deployment"
echo "==================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found${NC}"
    echo "Please create .env file from .env.example"
    exit 1
fi

# Load environment variables
export $(cat .env | grep -v '^#' | xargs)

echo -e "${GREEN}✓${NC} Environment file loaded"

# Check Docker and Docker Compose
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Error: Docker Compose is not installed${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Docker and Docker Compose are installed"

# Check if postgres password is still default
if grep -q "POSTGRES_PASSWORD=postgres" .env; then
    echo -e "${YELLOW}Warning: Using default PostgreSQL password${NC}"
    echo "It's highly recommended to change it in production"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Stop existing services
echo ""
echo "Stopping existing services..."
docker-compose down

# Pull latest changes (if needed)
if [ "$1" == "--update" ]; then
    echo ""
    echo "Pulling latest changes..."
    git pull origin main
fi

# Build images
echo ""
echo "Building Docker images..."
docker-compose build --no-cache

# Start services
echo ""
echo "Starting services..."
docker-compose up -d

# Wait for services to be healthy
echo ""
echo "Waiting for services to be healthy..."
sleep 10

# Check service health
echo ""
echo "Checking service health..."

# Check Postgres
if docker-compose ps postgres | grep -q "healthy"; then
    echo -e "${GREEN}✓${NC} PostgreSQL is healthy"
else
    echo -e "${RED}✗${NC} PostgreSQL is not healthy"
fi

# Check Backend
if docker-compose ps backend | grep -q "healthy\|running"; then
    echo -e "${GREEN}✓${NC} Backend is running"
    
    # Test backend health endpoint
    if curl -f http://localhost:${BACKEND_PORT:-8000}/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Backend health check passed"
    else
        echo -e "${YELLOW}⚠${NC} Backend health check failed (may still be starting)"
    fi
else
    echo -e "${RED}✗${NC} Backend is not healthy"
fi

# Check Frontend
if docker-compose ps frontend | grep -q "healthy\|running"; then
    echo -e "${GREEN}✓${NC} Frontend is running"
else
    echo -e "${RED}✗${NC} Frontend is not healthy"
fi

# Check Nginx
if docker-compose ps nginx | grep -q "running"; then
    echo -e "${GREEN}✓${NC} Nginx is running"
    
    # Test nginx
    if curl -f http://localhost:${HTTP_PORT:-80}/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Nginx health check passed"
    else
        echo -e "${YELLOW}⚠${NC} Nginx health check failed"
    fi
else
    echo -e "${RED}✗${NC} Nginx is not running"
fi

# Show logs
echo ""
echo "==================================="
echo "Deployment complete!"
echo "==================================="
echo ""
echo "Access the application at:"
echo "  - Frontend: http://localhost:${HTTP_PORT:-80}"
echo "  - Backend API: http://localhost:${HTTP_PORT:-80}/api/v1"
echo "  - API Docs: http://localhost:${HTTP_PORT:-80}/docs"
echo ""
echo "To view logs:"
echo "  docker-compose logs -f"
echo ""
echo "To stop services:"
echo "  docker-compose down"
echo ""

# Show warnings if AI model is not configured
if [ ! -f "backend/models/model.gguf" ]; then
    echo -e "${YELLOW}Note: AI model not found at backend/models/model.gguf${NC}"
    echo "The CRM will work, but AI chat features will be limited."
    echo "See PRODUCTION.md for instructions on adding a model."
    echo ""
fi
