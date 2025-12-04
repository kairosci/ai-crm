.PHONY: help install install-backend install-frontend setup dev dev-backend dev-frontend build build-backend build-frontend test test-backend test-frontend clean clean-backend clean-frontend db-start db-stop db-create db-shell docker-up docker-down docker-clean lint lint-backend lint-frontend validate

# Default Python and Node executables
PYTHON := python3
NODE := node
NPM := npm
PIP := pip
DOCKER_COMPOSE := docker compose

# Directories
BACKEND_DIR := backend
FRONTEND_DIR := frontend
VENV_DIR := $(BACKEND_DIR)/venv

# Colors for output
CYAN := \033[0;36m
GREEN := \033[0;32m
YELLOW := \033[1;33m
RESET := \033[0m

# Default target
.DEFAULT_GOAL := help

## help: Display this help message
help:
	@echo "$(CYAN)AI-CRM Makefile Commands$(RESET)"
	@echo ""
	@echo "$(GREEN)Setup Commands:$(RESET)"
	@echo "  make install              - Install all dependencies (backend + frontend)"
	@echo "  make install-backend      - Install backend Python dependencies"
	@echo "  make install-frontend     - Install frontend Node dependencies"
	@echo "  make setup                - Complete project setup (install + db)"
	@echo ""
	@echo "$(GREEN)Development Commands:$(RESET)"
	@echo "  make dev                  - Run both backend and frontend in parallel"
	@echo "  make dev-backend          - Run backend development server"
	@echo "  make dev-frontend         - Run frontend development server"
	@echo ""
	@echo "$(GREEN)Build Commands:$(RESET)"
	@echo "  make build                - Build both backend and frontend"
	@echo "  make build-backend        - Build backend (validate)"
	@echo "  make build-frontend       - Build frontend for production"
	@echo ""
	@echo "$(GREEN)Test Commands:$(RESET)"
	@echo "  make test                 - Run all tests"
	@echo "  make test-backend         - Run backend tests"
	@echo "  make test-frontend        - Run frontend tests"
	@echo ""
	@echo "$(GREEN)Database Commands:$(RESET)"
	@echo "  make db-start             - Start PostgreSQL using Docker"
	@echo "  make db-stop              - Stop PostgreSQL Docker container"
	@echo "  make db-create            - Create the CRM database"
	@echo "  make db-shell             - Open PostgreSQL shell"
	@echo ""
	@echo "$(GREEN)Docker Commands:$(RESET)"
	@echo "  make docker-up            - Start all services with docker-compose"
	@echo "  make docker-down          - Stop all services"
	@echo "  make docker-clean         - Stop and remove all containers and volumes"
	@echo ""
	@echo "$(GREEN)Linting Commands:$(RESET)"
	@echo "  make lint                 - Lint both backend and frontend"
	@echo "  make lint-backend         - Lint backend Python code"
	@echo "  make lint-frontend        - Lint frontend TypeScript code"
	@echo ""
	@echo "$(GREEN)Validation Commands:$(RESET)"
	@echo "  make validate             - Run backend validation script"
	@echo ""
	@echo "$(GREEN)Clean Commands:$(RESET)"
	@echo "  make clean                - Clean all build artifacts"
	@echo "  make clean-backend        - Clean backend artifacts"
	@echo "  make clean-frontend       - Clean frontend artifacts"
	@echo ""

## install: Install all dependencies
install: install-backend install-frontend
	@echo "$(GREEN)✓ All dependencies installed successfully$(RESET)"

## install-backend: Install backend dependencies
install-backend:
	@echo "$(CYAN)Installing backend dependencies...$(RESET)"
	@cd $(BACKEND_DIR) && \
		if [ ! -d "venv" ]; then \
			$(PYTHON) -m venv venv; \
		fi && \
		. venv/bin/activate && \
		$(PIP) install --upgrade pip && \
		$(PIP) install -r requirements.txt
	@echo "$(GREEN)✓ Backend dependencies installed$(RESET)"

## install-frontend: Install frontend dependencies
install-frontend:
	@echo "$(CYAN)Installing frontend dependencies...$(RESET)"
	@cd $(FRONTEND_DIR) && $(NPM) install
	@echo "$(GREEN)✓ Frontend dependencies installed$(RESET)"

## setup: Complete project setup
setup: install db-start
	@echo "$(CYAN)Setting up environment files...$(RESET)"
	@if [ ! -f $(BACKEND_DIR)/.env ]; then \
		cp $(BACKEND_DIR)/.env.example $(BACKEND_DIR)/.env; \
		echo "$(YELLOW)Created backend/.env from .env.example$(RESET)"; \
		echo "$(YELLOW)Please update MODEL_PATH in backend/.env if you want to use AI features$(RESET)"; \
	fi
	@sleep 5
	@$(MAKE) db-create
	@echo "$(GREEN)✓ Setup complete! Run 'make dev' to start development servers$(RESET)"

## dev: Run both backend and frontend development servers
dev:
	@echo "$(CYAN)Starting development servers...$(RESET)"
	@echo "$(YELLOW)Backend will be available at http://localhost:8000$(RESET)"
	@echo "$(YELLOW)Frontend will be available at http://localhost:3000$(RESET)"
	@trap 'kill 0' INT; \
		$(MAKE) dev-backend & \
		$(MAKE) dev-frontend & \
		wait

## dev-backend: Run backend development server
dev-backend:
	@echo "$(CYAN)Starting backend server...$(RESET)"
	@cd $(BACKEND_DIR) && . venv/bin/activate && $(PYTHON) run.py

## dev-frontend: Run frontend development server
dev-frontend:
	@echo "$(CYAN)Starting frontend server...$(RESET)"
	@cd $(FRONTEND_DIR) && $(NPM) run dev

## build: Build both backend and frontend
build: build-backend build-frontend
	@echo "$(GREEN)✓ Build complete$(RESET)"

## build-backend: Validate backend code
build-backend:
	@echo "$(CYAN)Validating backend...$(RESET)"
	@cd $(BACKEND_DIR) && . venv/bin/activate && $(PYTHON) validate.py
	@echo "$(GREEN)✓ Backend validated$(RESET)"

## build-frontend: Build frontend for production
build-frontend:
	@echo "$(CYAN)Building frontend...$(RESET)"
	@cd $(FRONTEND_DIR) && $(NPM) run build
	@echo "$(GREEN)✓ Frontend built$(RESET)"

## test: Run all tests
test: test-backend test-frontend
	@echo "$(GREEN)✓ All tests completed$(RESET)"

## test-backend: Run backend tests
test-backend:
	@echo "$(CYAN)Running backend tests...$(RESET)"
	@cd $(BACKEND_DIR) && . venv/bin/activate && \
		if [ -f pytest.ini ] || [ -d tests ]; then \
			$(PYTHON) -m pytest; \
		else \
			echo "$(YELLOW)No backend tests found$(RESET)"; \
		fi

## test-frontend: Run frontend tests
test-frontend:
	@echo "$(CYAN)Running frontend tests...$(RESET)"
	@cd $(FRONTEND_DIR) && \
		if $(NPM) run | grep -q test; then \
			$(NPM) test; \
		else \
			echo "$(YELLOW)No frontend tests configured$(RESET)"; \
		fi

## db-start: Start PostgreSQL using Docker
db-start:
	@echo "$(CYAN)Starting PostgreSQL...$(RESET)"
	@$(DOCKER_COMPOSE) up -d postgres
	@echo "$(GREEN)✓ PostgreSQL started$(RESET)"

## db-stop: Stop PostgreSQL
db-stop:
	@echo "$(CYAN)Stopping PostgreSQL...$(RESET)"
	@$(DOCKER_COMPOSE) stop postgres
	@echo "$(GREEN)✓ PostgreSQL stopped$(RESET)"

## db-create: Create the CRM database
db-create:
	@echo "$(CYAN)Creating CRM database...$(RESET)"
	@$(DOCKER_COMPOSE) exec -T postgres psql -U postgres -c "SELECT 1 FROM pg_database WHERE datname = 'crm_db'" | grep -q 1 || \
		$(DOCKER_COMPOSE) exec -T postgres createdb -U postgres crm_db
	@echo "$(GREEN)✓ Database ready$(RESET)"

## db-shell: Open PostgreSQL shell
db-shell:
	@echo "$(CYAN)Opening PostgreSQL shell...$(RESET)"
	@$(DOCKER_COMPOSE) exec postgres psql -U postgres -d crm_db

## docker-up: Start all services with docker-compose
docker-up:
	@echo "$(CYAN)Starting all Docker services...$(RESET)"
	@$(DOCKER_COMPOSE) up -d
	@echo "$(GREEN)✓ All services started$(RESET)"

## docker-down: Stop all Docker services
docker-down:
	@echo "$(CYAN)Stopping all Docker services...$(RESET)"
	@$(DOCKER_COMPOSE) down
	@echo "$(GREEN)✓ All services stopped$(RESET)"

## docker-clean: Stop and remove all containers and volumes
docker-clean:
	@echo "$(CYAN)Cleaning Docker environment...$(RESET)"
	@$(DOCKER_COMPOSE) down -v
	@echo "$(GREEN)✓ Docker environment cleaned$(RESET)"

## lint: Lint both backend and frontend
lint: lint-backend lint-frontend
	@echo "$(GREEN)✓ Linting complete$(RESET)"

## lint-backend: Lint backend code
lint-backend:
	@echo "$(CYAN)Linting backend code...$(RESET)"
	@cd $(BACKEND_DIR) && . venv/bin/activate && \
		if $(PYTHON) -m pip show flake8 > /dev/null 2>&1; then \
			$(PYTHON) -m flake8 app; \
		elif $(PYTHON) -m pip show pylint > /dev/null 2>&1; then \
			$(PYTHON) -m pylint app; \
		else \
			echo "$(YELLOW)No linter installed (install flake8 or pylint)$(RESET)"; \
		fi

## lint-frontend: Lint frontend code
lint-frontend:
	@echo "$(CYAN)Linting frontend code...$(RESET)"
	@cd $(FRONTEND_DIR) && $(NPM) run lint

## validate: Run backend validation
validate:
	@echo "$(CYAN)Running backend validation...$(RESET)"
	@cd $(BACKEND_DIR) && . venv/bin/activate && $(PYTHON) validate.py
	@echo "$(GREEN)✓ Validation complete$(RESET)"

## clean: Clean all build artifacts
clean: clean-backend clean-frontend
	@echo "$(GREEN)✓ Cleanup complete$(RESET)"

## clean-backend: Clean backend artifacts
clean-backend:
	@echo "$(CYAN)Cleaning backend artifacts...$(RESET)"
	@cd $(BACKEND_DIR) && \
		find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true && \
		find . -type f -name "*.pyc" -delete 2>/dev/null || true && \
		find . -type f -name "*.pyo" -delete 2>/dev/null || true && \
		find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	@echo "$(GREEN)✓ Backend cleaned$(RESET)"

## clean-frontend: Clean frontend artifacts
clean-frontend:
	@echo "$(CYAN)Cleaning frontend artifacts...$(RESET)"
	@cd $(FRONTEND_DIR) && \
		rm -rf .next 2>/dev/null || true && \
		rm -rf out 2>/dev/null || true
	@echo "$(GREEN)✓ Frontend cleaned$(RESET)"
