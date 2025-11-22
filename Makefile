.PHONY: help build up down logs restart clean backup restore dev-up prod-up test

# Default target
help:
	@echo "AI-CRM Management Commands"
	@echo "=========================="
	@echo ""
	@echo "Development:"
	@echo "  make dev-up          Start development environment (database only)"
	@echo "  make dev-backend     Run backend in development mode"
	@echo "  make dev-frontend    Run frontend in development mode"
	@echo ""
	@echo "Production:"
	@echo "  make prod-up         Start production environment"
	@echo "  make deploy          Deploy with automated script"
	@echo ""
	@echo "Common:"
	@echo "  make build           Build all Docker images"
	@echo "  make up              Start all services"
	@echo "  make down            Stop all services"
	@echo "  make restart         Restart all services"
	@echo "  make logs            View logs from all services"
	@echo "  make logs-backend    View backend logs"
	@echo "  make logs-frontend   View frontend logs"
	@echo "  make clean           Remove all containers and volumes"
	@echo ""
	@echo "Database:"
	@echo "  make backup          Create database backup"
	@echo "  make restore         Restore database from backup"
	@echo "  make db-shell        Open PostgreSQL shell"
	@echo ""
	@echo "Testing:"
	@echo "  make test            Run all tests"
	@echo "  make test-backend    Run backend tests"
	@echo "  make test-frontend   Run frontend tests"
	@echo ""
	@echo "Maintenance:"
	@echo "  make ps              Show running containers"
	@echo "  make health          Check service health"

# Development
dev-up:
	docker-compose -f docker-compose.dev.yml up -d
	@echo "Development database started on port 5432"

dev-backend:
	@echo "Starting backend in development mode..."
	cd backend && python run.py

dev-frontend:
	@echo "Starting frontend in development mode..."
	cd frontend && npm run dev

# Production
prod-up:
	docker-compose up -d

deploy:
	@chmod +x scripts/deploy.sh
	./scripts/deploy.sh

# Common Docker operations
build:
	docker-compose build

up:
	docker-compose up -d

down:
	docker-compose down

restart:
	docker-compose restart

logs:
	docker-compose logs -f

logs-backend:
	docker-compose logs -f backend

logs-frontend:
	docker-compose logs -f frontend

logs-postgres:
	docker-compose logs -f postgres

logs-nginx:
	docker-compose logs -f nginx

clean:
	docker-compose down -v
	@echo "Warning: This removed all data volumes!"

# Database operations
backup:
	@chmod +x scripts/backup.sh
	./scripts/backup.sh

restore:
	@chmod +x scripts/restore.sh
	@echo "Usage: make restore FILE=<backup_file>"
	@if [ -z "$(FILE)" ]; then \
		echo "Please specify backup file: make restore FILE=backups/backup.sql.gz"; \
	else \
		./scripts/restore.sh $(FILE); \
	fi

db-shell:
	docker-compose exec postgres psql -U postgres crm_db

# Testing
test: test-backend test-frontend

test-backend:
	@echo "Running backend tests..."
	cd backend && python -m pytest

test-frontend:
	@echo "Running frontend tests..."
	cd frontend && npm test

# Maintenance
ps:
	docker-compose ps

health:
	@echo "Checking service health..."
	@curl -s http://localhost/health > /dev/null && echo "✓ Nginx: healthy" || echo "✗ Nginx: unhealthy"
	@curl -s http://localhost:8000/health > /dev/null && echo "✓ Backend: healthy" || echo "✗ Backend: unhealthy"
	@docker-compose exec postgres pg_isready -U postgres > /dev/null && echo "✓ PostgreSQL: healthy" || echo "✗ PostgreSQL: unhealthy"

# Setup
install-deps-backend:
	cd backend && pip install -r requirements.txt

install-deps-frontend:
	cd frontend && npm install

setup-dev: install-deps-backend install-deps-frontend
	@echo "Development dependencies installed"
	@echo "Create .env files from examples:"
	@echo "  cp .env.example .env"
	@echo "  cp backend/.env.example backend/.env"

# Linting
lint-backend:
	cd backend && flake8 .

lint-frontend:
	cd frontend && npm run lint

lint: lint-backend lint-frontend
