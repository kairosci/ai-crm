# Quick Start Guide

Get the AI-CRM system up and running in minutes.

## Prerequisites

- Docker 20.10+
- Docker Compose 2.0+
- 4GB RAM minimum (8GB recommended with AI model)

## Option 1: Quick Production Deploy (Recommended)

### 1. Clone and Configure

```bash
# Clone repository
git clone https://github.com/kairosci/ai-crm.git
cd ai-crm

# Create environment file
cp .env.example .env

# Edit .env with your settings (optional for testing)
nano .env
```

### 2. Deploy with One Command

```bash
# Make script executable and run
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

Or use Make:

```bash
make deploy
```

### 3. Access the Application

- **Frontend**: http://localhost
- **API Documentation**: http://localhost/docs
- **Backend Health**: http://localhost:8000/health

That's it! 🎉

## Option 2: Development Setup

### 1. Start Database Only

```bash
make dev-up
# or
docker-compose -f docker-compose.dev.yml up -d
```

### 2. Run Backend Locally

```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt

# Create .env file
cp .env.example .env

# Run backend
python run.py
```

Backend will be available at http://localhost:8000

### 3. Run Frontend Locally

```bash
cd frontend
npm install
npm run dev
```

Frontend will be available at http://localhost:3000

## Option 3: Full Docker Stack

```bash
# Build and start all services
make build
make up

# Or with docker-compose directly
docker-compose build
docker-compose up -d

# View logs
make logs
```

## Adding AI Model (Optional)

The CRM works without an AI model - only the chat feature requires it.

### Download a Model

```bash
# Create models directory
mkdir -p backend/models

# Download TinyLlama (small, fast model - 1.1GB)
cd backend/models
wget https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf
mv tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf model.gguf
cd ../..
```

### Restart Backend

```bash
make restart
# or
docker-compose restart backend
```

## Useful Commands

### Management

```bash
make help              # Show all available commands
make ps                # Show running services
make health            # Check service health
make logs              # View all logs
make logs-backend      # View backend logs only
make restart           # Restart all services
make down              # Stop all services
```

### Database

```bash
make backup            # Create database backup
make db-shell          # Open PostgreSQL shell
make restore FILE=backup.sql.gz  # Restore from backup
```

### Development

```bash
make dev-up            # Start dev database
make dev-backend       # Run backend locally
make dev-frontend      # Run frontend locally
make lint              # Run linters
make test              # Run tests
```

## Default Credentials

- **Database**: postgres / postgres
- **Database Name**: crm_db

⚠️ **Change these in production!** Edit `.env` file.

## First Steps After Installation

1. **Access the frontend** at http://localhost
2. **Explore the API docs** at http://localhost/docs
3. **Create your first contact**:
   - Go to Contacts page
   - Click "Add Contact"
   - Fill in details
4. **Try the AI Chat** (if model is installed):
   - Go to AI Chat page
   - Ask: "Show me all contacts"
   - Or: "Create a contact named John Doe"

## Troubleshooting

### Services Not Starting

```bash
# Check service status
make ps

# View logs
make logs

# Check specific service
make logs-backend
```

### Port Already in Use

Edit `.env` file:
```bash
HTTP_PORT=8080        # Change from 80
BACKEND_PORT=8001     # Change from 8000
FRONTEND_PORT=3001    # Change from 3000
```

Then restart:
```bash
make down
make up
```

### Database Connection Failed

```bash
# Wait for database to be ready
docker-compose ps postgres

# Check database logs
make logs-postgres

# Restart backend after database is ready
make restart
```

### Can't Access from Browser

- Check firewall settings
- Ensure ports are not blocked
- Try http://127.0.0.1 instead of localhost

## Production Deployment

For production deployment with HTTPS, monitoring, and backups:

📖 **See [PRODUCTION.md](PRODUCTION.md)** for complete guide

Key production steps:
1. Generate strong passwords in `.env`
2. Set up SSL certificates (see `nginx/README.md`)
3. Configure domain name
4. Enable HTTPS in nginx
5. Set up backups
6. Configure monitoring

## Next Steps

- 📖 Read [README.md](README.md) for feature overview
- 🔧 Read [PRODUCTION.md](PRODUCTION.md) for production deployment
- ✅ Check [TODO.md](TODO.md) for roadmap and future features
- 📚 Explore API at http://localhost/docs

## Getting Help

- **Check logs**: `make logs`
- **View documentation**: See docs/ directory
- **Report issues**: GitHub Issues
- **Read troubleshooting**: See PRODUCTION.md

## License

See LICENSE file for details.
