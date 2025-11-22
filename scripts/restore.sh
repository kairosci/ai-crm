#!/bin/bash
# Database Restore Script for AI-CRM

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo "==================================="
echo "AI-CRM Database Restore"
echo "==================================="

# Check if backup file is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: No backup file specified${NC}"
    echo "Usage: $0 <backup_file.sql.gz>"
    echo ""
    echo "Available backups:"
    ls -lh ./backups/*.sql.gz 2>/dev/null || echo "No backups found"
    exit 1
fi

BACKUP_FILE="$1"

# Check if file exists
if [ ! -f "${BACKUP_FILE}" ]; then
    echo -e "${RED}Error: Backup file not found: ${BACKUP_FILE}${NC}"
    exit 1
fi

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_DB="${POSTGRES_DB:-crm_db}"

echo -e "${YELLOW}WARNING: This will replace the current database!${NC}"
echo "Database: ${POSTGRES_DB}"
echo "Backup file: ${BACKUP_FILE}"
echo ""
read -p "Are you sure you want to continue? (yes/NO) " -r
echo

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Restore cancelled"
    exit 0
fi

echo "Decompressing backup..."
if [[ "${BACKUP_FILE}" == *.gz ]]; then
    gunzip -c "${BACKUP_FILE}" > /tmp/restore_temp.sql
    RESTORE_FILE="/tmp/restore_temp.sql"
else
    RESTORE_FILE="${BACKUP_FILE}"
fi

echo "Restoring database..."
if cat "${RESTORE_FILE}" | docker-compose exec -T postgres psql -U "${POSTGRES_USER}" "${POSTGRES_DB}"; then
    echo -e "${GREEN}✓${NC} Database restored successfully"
    
    # Clean up temp file
    if [ "${RESTORE_FILE}" == "/tmp/restore_temp.sql" ]; then
        rm -f /tmp/restore_temp.sql
    fi
else
    echo -e "${RED}✗${NC} Restore failed"
    rm -f /tmp/restore_temp.sql
    exit 1
fi

echo ""
echo "==================================="
echo "Restore complete!"
echo "==================================="
