# Production Deployment

## Services

| Service      | Port | Description                          |
|-------------|------|--------------------------------------|
| storefront  | 3000 | Next.js storefront (فروشگاه مشتری)   |
| dashboard   | 9001 | Saleor Dashboard (پنل مدیریت)        |
| api         | 8000 | Django GraphQL backend               |
| worker      | -    | Celery async tasks (email, webhooks) |
| beat        | -    | Celery scheduled tasks               |
| db          | -    | PostgreSQL 15                        |
| redis       | -    | Valkey/Redis cache & broker          |

## First-Time Setup

```powershell
cd production

# 1. Configure environment
cp .env.example .env
# Edit .env - at minimum change: POSTGRES_PASSWORD, SECRET_KEY, SALEOR_WEBHOOK_SECRET, REVALIDATE_SECRET

# 2. Start backend services
docker compose up -d db redis api worker beat dashboard

# 3. Wait for API to be ready, then build & start storefront
.\deploy.ps1

# 4. Create admin user
docker compose exec api python manage.py createsuperuser
```

## Subsequent Deploys

```powershell
# Rebuild everything
.\deploy.ps1 -Rebuild

# Rebuild only backend (storefront unchanged)
docker compose build --no-cache api worker beat
docker compose up -d

# Rebuild only storefront (after API is running)
.\deploy.ps1 -Rebuild -SkipBackend  # not implemented - run manually:
docker build --network=host --build-arg NEXT_PUBLIC_SALEOR_API_URL=http://localhost:8000/graphql/ -f production/Dockerfile.storefront -t production-storefront ..
docker compose up -d storefront
```

## Useful Commands

```powershell
# View logs
docker compose logs -f api
docker compose logs -f worker
docker compose logs -f beat

# Run migrations manually
docker compose exec api python manage.py migrate

# Populate with test data
docker compose exec api python manage.py populatedb --withoutimages

# Django shell
docker compose exec api python manage.py shell

# Stop all
docker compose down

# Stop and delete all data (WARNING!)
docker compose down -v
```

## Webhook Setup (Cache Invalidation)

For instant storefront cache updates when products/categories change:

1. Go to Dashboard → Configuration → Webhooks → Create Webhook
2. Name: `Storefront Cache Invalidation`
3. Target URL: `http://storefront:3000/api/revalidate`
4. Secret Key: same value as `SALEOR_WEBHOOK_SECRET` in `.env`
5. Subscribe to events:
   - `PRODUCT_UPDATED`, `PRODUCT_CREATED`, `PRODUCT_DELETED`
   - `CATEGORY_UPDATED`
   - `COLLECTION_UPDATED`
   - `PAGE_UPDATED`

Without webhooks, storefront cache expires automatically every 5 minutes.

## Production Checklist

- [ ] `SECRET_KEY` - long random string (50+ chars)
- [ ] `POSTGRES_PASSWORD` - strong password
- [ ] `DEBUG=False`
- [ ] `ALLOWED_HOSTS` - your actual domain
- [ ] `ALLOWED_CLIENT_HOSTS` - your actual domain
- [ ] `ALLOWED_GRAPHQL_ORIGINS` - storefront and dashboard URLs
- [ ] `PUBLIC_URL` - public API URL
- [ ] `RSA_PRIVATE_KEY` - required when DEBUG=False
- [ ] `EMAIL_URL` - real SMTP server
- [ ] `SALEOR_WEBHOOK_SECRET` - min 32 chars
- [ ] `REVALIDATE_SECRET` - min 32 chars
- [ ] Set up HTTPS with nginx/Traefik reverse proxy
- [ ] Configure media file storage (S3/GCS for production)
- [ ] Set up database backups

## Generate RSA Key

```bash
# Linux/Mac
openssl genrsa 2048 | awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}'

# Windows PowerShell
openssl genrsa 2048 | ForEach-Object { $_ -replace "`r", "" } | Join-String -Separator "\n"
```

Paste the output as the value of `RSA_PRIVATE_KEY` in `.env`.
