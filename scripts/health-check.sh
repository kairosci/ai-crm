#!/bin/bash
# Health Check Script for AI-CRM
# Returns 0 if all services are healthy, 1 otherwise

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Load environment safely
if [ -f .env ]; then
    set -a
    source .env
    set +a
fi

HTTP_PORT="${HTTP_PORT:-80}"
BACKEND_PORT="${BACKEND_PORT:-8000}"
POSTGRES_USER="${POSTGRES_USER:-postgres}"

FAILED=0

echo "======================================="
echo "AI-CRM Health Check"
echo "======================================="
echo ""

# Check Nginx
echo -n "Checking Nginx... "
if curl -sf http://localhost:${HTTP_PORT}/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Healthy${NC}"
else
    echo -e "${RED}✗ Unhealthy${NC}"
    FAILED=1
fi

# Check Backend
echo -n "Checking Backend... "
if curl -sf http://localhost:${BACKEND_PORT}/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Healthy${NC}"
    
    # Get backend response
    RESPONSE=$(curl -s http://localhost:${BACKEND_PORT}/health)
    echo "  Response: $RESPONSE"
else
    echo -e "${RED}✗ Unhealthy${NC}"
    FAILED=1
fi

# Check PostgreSQL
echo -n "Checking PostgreSQL... "
if docker-compose exec -T postgres pg_isready -U ${POSTGRES_USER} > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Healthy${NC}"
    
    # Check database connection count
    CONN_COUNT=$(docker-compose exec -T postgres psql -U ${POSTGRES_USER} -t -c "SELECT count(*) FROM pg_stat_activity;" 2>/dev/null | xargs)
    if [ ! -z "$CONN_COUNT" ]; then
        echo "  Active connections: $CONN_COUNT"
    fi
else
    echo -e "${RED}✗ Unhealthy${NC}"
    FAILED=1
fi

# Check Frontend (if running in Docker)
if docker-compose ps frontend 2>/dev/null | grep -q "running"; then
    echo -n "Checking Frontend... "
    if docker-compose exec -T frontend wget --no-verbose --tries=1 --spider http://localhost:3000 2>/dev/null; then
        echo -e "${GREEN}✓ Healthy${NC}"
    else
        echo -e "${YELLOW}⚠ Frontend container running but health check failed${NC}"
    fi
fi

# Check disk space
echo ""
echo "Disk Usage:"
df -h / | tail -1 | awk '{print "  Root: " $3 " used of " $2 " (" $5 " full)"}'

# Check Docker disk usage
if command -v docker &> /dev/null; then
    echo ""
    echo "Docker Disk Usage:"
    docker system df --format "table {{.Type}}\t{{.Size}}"
fi

# Check memory
echo ""
echo "Memory Usage:"
free -h | grep "Mem:" | awk '{print "  Total: " $2 " | Used: " $3 " | Available: " $7}'

# Summary
echo ""
echo "======================================="
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All services are healthy ✓${NC}"
    exit 0
else
    echo -e "${RED}Some services are unhealthy ✗${NC}"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Check logs: make logs"
    echo "  2. Check containers: make ps"
    echo "  3. Restart services: make restart"
    exit 1
fi
