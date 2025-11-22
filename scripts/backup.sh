#!/bin/bash
# Database Backup Script for AI-CRM

set -e

# Configuration
BACKUP_DIR="${BACKUP_DIR:-./backups}"
RETENTION_DAYS="${RETENTION_DAYS:-30}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/crm_backup_${TIMESTAMP}.sql"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "==================================="
echo "AI-CRM Database Backup"
echo "==================================="

# Create backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}"

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_DB="${POSTGRES_DB:-crm_db}"

echo "Creating backup..."
echo "Database: ${POSTGRES_DB}"
echo "Output: ${BACKUP_FILE}"

# Create backup
if docker-compose exec -T postgres pg_dump -U "${POSTGRES_USER}" "${POSTGRES_DB}" > "${BACKUP_FILE}"; then
    echo -e "${GREEN}✓${NC} Backup created successfully"
    
    # Compress backup
    gzip "${BACKUP_FILE}"
    echo -e "${GREEN}✓${NC} Backup compressed: ${BACKUP_FILE}.gz"
    
    # Show backup size
    SIZE=$(du -h "${BACKUP_FILE}.gz" | cut -f1)
    echo "Backup size: ${SIZE}"
else
    echo -e "${RED}✗${NC} Backup failed"
    exit 1
fi

# Clean up old backups
echo ""
echo "Cleaning up old backups (older than ${RETENTION_DAYS} days)..."
find "${BACKUP_DIR}" -name "crm_backup_*.sql.gz" -mtime +${RETENTION_DAYS} -delete
echo -e "${GREEN}✓${NC} Cleanup complete"

# List recent backups
echo ""
echo "Recent backups:"
ls -lh "${BACKUP_DIR}" | tail -5

echo ""
echo "==================================="
echo "Backup complete!"
echo "==================================="
