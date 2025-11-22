# Production Deployment Guide

This guide covers deploying the Enterprise CRM system in a production environment.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Configuration](#configuration)
3. [Docker Deployment](#docker-deployment)
4. [Security Considerations](#security-considerations)
5. [Monitoring and Maintenance](#monitoring-and-maintenance)
6. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Software
- Docker 20.10+
- Docker Compose 2.0+
- Git
- (Optional) GGUF model file for AI features

### System Requirements
- **Minimum**: 4GB RAM, 2 CPU cores, 20GB storage
- **Recommended**: 8GB RAM, 4 CPU cores, 50GB storage
- **With AI Model**: Add 4-8GB RAM depending on model size

## Configuration

### 1. Clone the Repository

```bash
git clone https://github.com/kairosci/ai-crm.git
cd ai-crm
```

### 2. Environment Configuration

Copy the example environment file:

```bash
cp .env.example .env
```

Edit `.env` with your production settings:

```bash
# Database - Use strong passwords!
POSTGRES_USER=crm_user
POSTGRES_PASSWORD=CHANGE_THIS_STRONG_PASSWORD
POSTGRES_DB=crm_production
POSTGRES_PORT=5432

# Backend
BACKEND_PORT=8000
DATABASE_URL=postgresql://crm_user:CHANGE_THIS_STRONG_PASSWORD@postgres:5432/crm_production

# AI Model (optional)
MODEL_PATH=/app/models/model.gguf
MODEL_N_CTX=2048
MODEL_N_GPU_LAYERS=0  # Set to >0 if you have GPU

# Frontend
FRONTEND_PORT=3000
NEXT_PUBLIC_API_URL=http://your-domain.com/api/v1  # Change to your domain

# Nginx
HTTP_PORT=80
HTTPS_PORT=443

# Security
SECRET_KEY=$(openssl rand -hex 32)
JWT_SECRET=$(openssl rand -hex 32)
ALLOWED_ORIGINS=https://your-domain.com

# Environment
NODE_ENV=production
PYTHON_ENV=production
LOG_LEVEL=INFO
```

### 3. AI Model Setup (Optional)

If you want AI chat functionality:

1. Download a GGUF model file:
   ```bash
   # Example: Download TinyLlama
   mkdir -p backend/models
   cd backend/models
   wget https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf
   mv tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf model.gguf
   cd ../..
   ```

2. Update MODEL_PATH in `.env` if needed.

**Note**: The system works without AI models - only the chat feature will be limited.

### 4. SSL/TLS Certificates (Recommended)

For HTTPS support:

1. Generate certificates:
   ```bash
   # Self-signed certificate (development/testing)
   mkdir -p nginx/ssl
   openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
     -keyout nginx/ssl/key.pem \
     -out nginx/ssl/cert.pem
   
   # For production, use Let's Encrypt:
   # Install certbot and obtain certificates
   # Then copy to nginx/ssl/
   ```

2. Update `nginx/nginx.conf`:
   - Uncomment HTTPS server block
   - Update `server_name` with your domain
   - Enable HTTPS redirect

## Docker Deployment

### Build and Start All Services

```bash
# Build images
docker-compose build

# Start services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

### Individual Service Management

```bash
# Start specific service
docker-compose up -d postgres

# Restart service
docker-compose restart backend

# Stop all services
docker-compose down

# Stop and remove volumes (CAUTION: deletes data)
docker-compose down -v
```

## Security Considerations

### 1. Environment Variables

- **Never commit** `.env` file to version control
- Use strong, unique passwords for database
- Rotate secrets regularly
- Use different credentials for each environment

### 2. Database Security

```bash
# Change default PostgreSQL password immediately
# Update DATABASE_URL in .env accordingly
```

### 3. Network Security

- Configure firewall to allow only necessary ports
- Use private networks for inter-service communication
- Enable HTTPS with valid SSL certificates
- Implement rate limiting (configured in nginx)

### 4. Application Security

- Keep dependencies updated
- Regular security audits
- Enable security headers (configured in nginx)
- Monitor logs for suspicious activity

### 5. CORS Configuration

Update `ALLOWED_ORIGINS` in `.env`:
```bash
ALLOWED_ORIGINS=https://your-domain.com,https://www.your-domain.com
```

## Monitoring and Maintenance

### Health Checks

All services have health check endpoints:

```bash
# Nginx health
curl http://localhost/health

# Backend health
curl http://localhost:8000/health

# Check all container health
docker-compose ps
```

### Log Management

```bash
# View all logs
docker-compose logs

# View specific service logs
docker-compose logs backend
docker-compose logs frontend
docker-compose logs postgres

# Follow logs in real-time
docker-compose logs -f backend

# Save logs to file
docker-compose logs > logs_$(date +%Y%m%d).txt
```

### Database Backups

```bash
# Create backup
docker-compose exec postgres pg_dump -U postgres crm_db > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore backup
cat backup_20240101_120000.sql | docker-compose exec -T postgres psql -U postgres crm_db

# Automated daily backup (add to crontab)
0 2 * * * cd /path/to/ai-crm && docker-compose exec postgres pg_dump -U postgres crm_db > /backups/crm_$(date +\%Y\%m\%d).sql
```

### Updates and Upgrades

```bash
# Pull latest code
git pull origin main

# Rebuild and restart services
docker-compose down
docker-compose build
docker-compose up -d

# Check for issues
docker-compose logs -f
```

### Resource Monitoring

```bash
# Monitor container resources
docker stats

# View container details
docker-compose top

# Check disk usage
df -h
docker system df
```

## Troubleshooting

### Common Issues

#### 1. Database Connection Failed

**Symptoms**: Backend can't connect to database

**Solutions**:
```bash
# Check database is running
docker-compose ps postgres

# Check database logs
docker-compose logs postgres

# Verify credentials in .env
# Wait for database to be healthy
docker-compose up -d postgres
sleep 10
docker-compose up -d backend
```

#### 2. Frontend Can't Reach Backend

**Symptoms**: API calls fail from frontend

**Solutions**:
```bash
# Check NEXT_PUBLIC_API_URL in .env
# For Docker network, use service name: http://backend:8000/api/v1
# For external access, use domain/IP

# Verify backend is running
docker-compose logs backend
curl http://localhost:8000/health

# Check CORS settings
# Update ALLOWED_ORIGINS in .env
```

#### 3. AI Chat Not Working

**Symptoms**: Chat returns errors or generic responses

**Solutions**:
```bash
# Check if model file exists
ls -lh backend/models/

# Check backend logs
docker-compose logs backend | grep -i "ai\|model"

# Verify MODEL_PATH in .env
# AI features are optional - rest of CRM works without them
```

#### 4. Port Already in Use

**Symptoms**: Can't start services, port conflict

**Solutions**:
```bash
# Check what's using the port
sudo lsof -i :80
sudo lsof -i :8000
sudo lsof -i :3000

# Change ports in .env
HTTP_PORT=8080
BACKEND_PORT=8001
FRONTEND_PORT=3001

# Restart services
docker-compose down
docker-compose up -d
```

#### 5. Out of Memory

**Symptoms**: Containers crash, OOM errors

**Solutions**:
```bash
# Check available memory
free -h

# Reduce AI model size or disable
# Use smaller context window
MODEL_N_CTX=1024

# Add swap space
# Upgrade server resources
```

### Useful Commands

```bash
# Reset everything (CAUTION: destroys data)
docker-compose down -v
docker system prune -a

# Enter container shell
docker-compose exec backend bash
docker-compose exec frontend sh
docker-compose exec postgres psql -U postgres crm_db

# Check environment variables in container
docker-compose exec backend env

# Rebuild single service
docker-compose build backend
docker-compose up -d --no-deps backend
```

## Performance Optimization

### 1. Database Optimization

```bash
# Inside database container
docker-compose exec postgres psql -U postgres crm_db

# Create indexes
CREATE INDEX idx_contacts_email ON contacts(email);
CREATE INDEX idx_deals_status ON deals(status);
CREATE INDEX idx_tasks_status ON tasks(status);
```

### 2. Backend Optimization

- Enable connection pooling in database.py
- Use caching for frequently accessed data
- Optimize AI model parameters (MODEL_N_CTX, MODEL_N_GPU_LAYERS)

### 3. Frontend Optimization

- Images are already optimized with Next.js
- Static assets cached by nginx (30 days)
- Gzip compression enabled

### 4. Nginx Optimization

- Adjust worker_connections in nginx.conf
- Fine-tune rate limiting
- Enable HTTP/2 (requires HTTPS)

## Scaling

### Horizontal Scaling

For high-traffic scenarios:

1. **Database**: Use PostgreSQL replication or managed database service
2. **Backend**: Run multiple backend containers behind a load balancer
3. **Frontend**: Use CDN for static assets

### Vertical Scaling

- Increase container resources in docker-compose.yml:
  ```yaml
  backend:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
  ```

## Production Checklist

Before going live:

- [ ] Strong passwords configured
- [ ] SSL/TLS certificates installed
- [ ] CORS properly configured
- [ ] Backup strategy implemented
- [ ] Monitoring set up
- [ ] Log rotation configured
- [ ] Firewall rules applied
- [ ] Domain DNS configured
- [ ] Health checks working
- [ ] Load testing completed
- [ ] Documentation updated
- [ ] Emergency procedures documented
- [ ] Team trained on deployment

## Support

For issues or questions:
- Check logs: `docker-compose logs`
- Review this guide
- Check GitHub issues
- Contact system administrator

## License

See LICENSE file for details.
