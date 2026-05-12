# راهنمای رفع مشکل تصاویر محصولات

## مشکل

تصاویر محصولات در Storefront نمایش داده نمی‌شدند و خطای زیر در Console مرورگر ظاهر می‌شد:

```
Failed to load resource: the server responded with a status of 400 (Bad Request)
http://localhost:3000/_next/image?url=http%3A%2F%2Flocalhost%3A8000%2Fthumbnail%2F...
```

## علت مشکل

1. **مشکل دسترسی از مرورگر**: مرورگر (client-side) نمی‌توانست به `localhost:8000` دسترسی داشته باشد چون API در کانتینر Docker اجرا می‌شد
2. **Next.js Image Optimization**: Next.js سعی می‌کرد تصاویر را از `localhost:8000` بگیرد که از سمت client قابل دسترسی نبود

## راه حل پیاده شده

### 1. اضافه کردن Nginx Reverse Proxy

یک Nginx reverse proxy اضافه کردیم که همه درخواست‌ها را مدیریت می‌کند:

```
مرورگر → Nginx (port 80) → API/Storefront/Dashboard
```

**مزایا:**
- ✅ همه سرویس‌ها از یک پورت (80) قابل دسترسی هستند
- ✅ تصاویر از طریق `/media/` و `/thumbnail/` قابل دسترسی هستند
- ✅ مشکل CORS حل شده
- ✅ ساختار شبیه به production

### 2. تنظیم Next.js Image Optimization

در `next.config.js` گزینه `unoptimized: true` را اضافه کردیم تا Next.js تصاویر را بدون optimization نمایش دهد.

### 3. به‌روزرسانی Environment Variables

URL های API را به `http://localhost/graphql/` تغییر دادیم تا از طریق Nginx قابل دسترسی باشند.

## آدرس‌های جدید

بعد از این تغییرات، همه سرویس‌ها از پورت 80 قابل دسترسی هستند:

| سرویس | آدرس قبلی | آدرس جدید |
|-------|-----------|-----------|
| **Storefront** | http://localhost:3000 | **http://localhost** |
| **Dashboard** | http://localhost:9001 | **http://localhost/dashboard/** |
| **API GraphQL** | http://localhost:8000/graphql/ | **http://localhost/graphql/** |
| **Media Files** | http://localhost:8000/media/ | **http://localhost/media/** |
| **Thumbnails** | http://localhost:8000/thumbnail/ | **http://localhost/thumbnail/** |

## ساختار فایل‌ها

```
production/
├── docker-compose.yml      # تنظیمات Docker با Nginx
├── nginx.conf              # تنظیمات Nginx reverse proxy
├── .env                    # متغیرهای محیطی
├── Dockerfile.storefront.dev
└── add_product_images.py   # اسکریپت اضافه کردن تصاویر
```

## تست کردن

### 1. بررسی وضعیت کانتینرها

```bash
docker ps
```

باید 8 کانتینر در حال اجرا باشند:
- ✅ nginx
- ✅ api
- ✅ storefront
- ✅ dashboard
- ✅ worker
- ✅ beat
- ✅ db
- ✅ redis

### 2. تست Storefront

1. مرورگر را باز کنید: **http://localhost**
2. باید صفحه اصلی فروشگاه با تصاویر محصولات نمایش داده شود

### 3. تست Dashboard

1. مرورگر را باز کنید: **http://localhost/dashboard/**
2. با اطلاعات admin وارد شوید:
   - ایمیل: `admin@example.com`
   - رمز عبور: `admin`

### 4. تست API

```bash
curl http://localhost/graphql/ -H "Content-Type: application/json" -d '{"query":"{ shop { name } }"}'
```

## عیب‌یابی

### تصاویر هنوز نمایش داده نمی‌شوند

1. **Cache مرورگر را پاک کنید**
   ```
   Ctrl + Shift + R (Windows/Linux)
   Cmd + Shift + R (Mac)
   ```

2. **Storefront را restart کنید**
   ```bash
   docker compose restart storefront
   ```

3. **لاگ‌های Nginx را بررسی کنید**
   ```bash
   docker logs production-nginx-1
   ```

4. **لاگ‌های API را بررسی کنید**
   ```bash
   docker logs production-api-1 --tail 50
   ```

### خطای 502 Bad Gateway

این یعنی Nginx نمی‌تواند به سرویس backend متصل شود.

**راه حل:**
```bash
# بررسی وضعیت سرویس‌ها
docker ps

# اگر سرویسی متوقف شده، آن را restart کنید
docker compose restart api
docker compose restart storefront
```

### خطای 404 Not Found

مسیر URL اشتباه است.

**راه حل:**
- Storefront: `http://localhost` (بدون `/`)
- Dashboard: `http://localhost/dashboard/` (با `/` در انتها)
- API: `http://localhost/graphql/` (با `/` در انتها)

### تصاویر با کیفیت پایین

چون `unoptimized: true` تنظیم شده، Next.js تصاویر را optimize نمی‌کند.

**راه حل برای production:**
1. از CDN استفاده کنید (مثل Cloudflare)
2. تصاویر را قبل از آپلود optimize کنید
3. از فرمت WEBP استفاده کنید

## دستورات مفید

### راه‌اندازی مجدد همه سرویس‌ها
```bash
cd production
docker compose down
docker compose up -d
```

### مشاهده لاگ‌های همه سرویس‌ها
```bash
docker compose logs -f
```

### مشاهده لاگ یک سرویس خاص
```bash
docker logs production-nginx-1 -f
docker logs production-api-1 -f
docker logs production-storefront-1 -f
```

### بررسی استفاده از منابع
```bash
docker stats
```

### پاک کردن همه چیز و شروع مجدد
```bash
docker compose down -v  # حذف volumes هم
docker compose up -d
```

## تنظیمات Production

برای استفاده در production، این تغییرات را اعمال کنید:

### 1. فعال کردن HTTPS

در `nginx.conf`:
```nginx
server {
    listen 443 ssl http2;
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    # ... rest of config
}
```

### 2. فعال کردن Image Optimization

در `next.config.js`:
```javascript
images: {
    unoptimized: false,  // فعال کردن optimization
    // ... rest of config
}
```

### 3. استفاده از CDN

تصاویر را روی CDN قرار دهید و در `next.config.js`:
```javascript
images: {
    domains: ['cdn.yourdomain.com'],
    // ... rest of config
}
```

### 4. تنظیم DEBUG=False

در `.env`:
```bash
DEBUG=False
SECRET_KEY=your-strong-secret-key
RSA_PRIVATE_KEY=your-rsa-key
```

## نکات امنیتی

⚠️ **هشدار**: این تنظیمات برای محیط توسعه (development) است.

برای production:
- ✅ `DEBUG=False` تنظیم کنید
- ✅ `SECRET_KEY` قوی تنظیم کنید
- ✅ `RSA_PRIVATE_KEY` تنظیم کنید
- ✅ HTTPS فعال کنید
- ✅ Firewall تنظیم کنید
- ✅ از environment variables برای secrets استفاده کنید
- ✅ ALLOWED_HOSTS را محدود کنید

## منابع

- [Nginx Documentation](https://nginx.org/en/docs/)
- [Next.js Image Optimization](https://nextjs.org/docs/app/building-your-application/optimizing/images)
- [Saleor Documentation](https://docs.saleor.io/)
- [Docker Compose](https://docs.docker.com/compose/)

---

## خلاصه تغییرات

✅ **اضافه شد:**
- Nginx reverse proxy
- تنظیمات nginx.conf
- Image optimization disabled

✅ **تغییر کرد:**
- آدرس‌های URL از localhost:PORT به localhost/PATH
- Environment variables
- Docker compose configuration

✅ **نتیجه:**
- تصاویر محصولات نمایش داده می‌شوند
- همه سرویس‌ها از یک پورت قابل دسترسی هستند
- ساختار شبیه به production
