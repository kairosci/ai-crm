# Nginx Configuration

This directory contains the nginx reverse proxy configuration for the AI-CRM application.

## Files

- `nginx.conf` - Main nginx configuration file
- `ssl/` - Directory for SSL/TLS certificates (optional, for HTTPS)

## SSL/TLS Setup

### Option 1: Self-Signed Certificate (Development/Testing)

Generate a self-signed certificate:

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/key.pem \
  -out ssl/cert.pem \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"
```

### Option 2: Let's Encrypt (Production)

1. Install Certbot:
```bash
sudo apt-get update
sudo apt-get install certbot
```

2. Obtain certificate (replace your-domain.com):
```bash
sudo certbot certonly --standalone -d your-domain.com
```

3. Copy certificates to nginx/ssl:
```bash
sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem ssl/cert.pem
sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem ssl/key.pem
```

4. Set up auto-renewal:
```bash
sudo crontab -e
# Add this line:
0 0 * * * certbot renew --quiet && cp /etc/letsencrypt/live/your-domain.com/*.pem /path/to/ai-crm/nginx/ssl/ && docker-compose restart nginx
```

### Option 3: Custom Certificate

If you have a certificate from a certificate authority:

1. Copy your certificate and private key:
```bash
cp /path/to/your/certificate.crt ssl/cert.pem
cp /path/to/your/private.key ssl/key.pem
```

2. Ensure proper permissions:
```bash
chmod 600 ssl/key.pem
chmod 644 ssl/cert.pem
```

## Enabling HTTPS

After setting up certificates:

1. Edit `nginx.conf`
2. Uncomment the HTTPS server block (lines with `# server {`)
3. Update `server_name` with your domain
4. Uncomment the HTTPS redirect in the HTTP server block
5. Restart nginx:
```bash
docker-compose restart nginx
```

## Configuration Options

### Rate Limiting

The configuration includes rate limiting:
- API endpoints: 10 requests/second (burst: 20)
- Chat endpoint: 2 requests/second (burst: 5)

Adjust in `nginx.conf`:
```nginx
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;
```

### Timeouts

- Standard API: 60 seconds
- AI Chat: 120 seconds (longer for AI processing)

### Gzip Compression

Enabled for:
- Text files (HTML, CSS, JS, JSON)
- Fonts (WOFF, TTF, etc.)
- XML and RSS feeds

### Caching

Static assets cached for 30 days with immutable cache control.

## Testing Configuration

Test nginx configuration before restarting:

```bash
docker-compose exec nginx nginx -t
```

## Troubleshooting

### 502 Bad Gateway

- Check backend/frontend containers are running: `docker-compose ps`
- Check backend/frontend logs: `docker-compose logs backend`

### SSL Certificate Errors

- Verify certificate files exist in `ssl/` directory
- Check file permissions
- Ensure certificate is valid and not expired

### Rate Limiting Issues

If legitimate users are being rate-limited:
- Increase rate in `nginx.conf`
- Adjust burst value
- Consider using different zones for different user types

## Security Headers

When HTTPS is enabled, the configuration adds:
- Strict-Transport-Security
- X-Frame-Options
- X-Content-Type-Options
- X-XSS-Protection

## Custom Configuration

To add custom nginx configuration:

1. Edit `nginx.conf`
2. Test configuration: `docker-compose exec nginx nginx -t`
3. Reload nginx: `docker-compose restart nginx`

## Production Checklist

- [ ] SSL certificates installed
- [ ] HTTPS enabled and HTTP redirects to HTTPS
- [ ] `server_name` updated with your domain
- [ ] Rate limiting configured appropriately
- [ ] Security headers enabled
- [ ] Certificate auto-renewal set up (if using Let's Encrypt)
- [ ] Firewall allows ports 80 and 443
