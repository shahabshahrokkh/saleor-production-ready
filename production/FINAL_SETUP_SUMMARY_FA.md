# خلاصه نهایی راه‌اندازی پروژه Saleor

## ✅ مشکلات حل شده

### 1. مشکل تصاویر محصولات
**مشکل**: تصاویر نمایش داده نمی‌شدند
**علت**: Next.js Image Optimization نمی‌توانست به API دسترسی داشته باشد
**راه حل**:
- `unoptimized: true` در `next.config.js`
- Port mapping مستقیم بدون nginx

### 2. مشکل Checkout
**مشکل**: `ERR_NAME_NOT_RESOLVED` برای `api:8000`
**علت**: Checkout از client-side rendering استفاده می‌کند و مرورگر نمی‌تواند hostname `api` را resolve کند
**راه حل**: استفاده از `http://localhost:8000/graphql/` برای دسترسی از مرورگر

## 🎯 تنظیمات نهایی

### Environment Variables

#### Server-side (Next.js Server)
- از `http://api:8000/graphql/` استفاده می‌کند (داخل Docker network)
- در `docker-compose.yml` تنظیم نشده (از .env.local استفاده می‌کند)

#### Client-side (مرورگر)
- از `http://localhost:8000/graphql/` استفاده می‌کند
- در `.env.local` و `docker-compose.yml` تنظیم شده

### فایل `.env.local` (storefront)
```env
NEXT_PUBLIC_SALEOR_API_URL=http://localhost:8000/graphql/
NEXT_PUBLIC_STOREFRONT_URL=http://localhost:3000
NEXT_PUBLIC_DEFAULT_CHANNEL=default-channel
```

### فایل `.env` (production)
```env
# Django
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1,api
ALLOWED_CLIENT_HOSTS=localhost,127.0.0.1
ALLOWED_GRAPHQL_ORIGINS=http://localhost:3000,http://localhost:9001

# Storefront
NEXT_PUBLIC_SALEOR_API_URL=http://localhost:8000/graphql/
NEXT_PUBLIC_STOREFRONT_URL=http://localhost:3000
NEXT_PUBLIC_DEFAULT_CHANNEL=default-channel
```

## 🌐 آدرس‌های دسترسی

| سرویس | آدرس | توضیحات |
|-------|------|---------|
| 🏪 **Storefront** | http://localhost:3000 | فروشگاه اصلی |
| 📊 **Dashboard** | http://localhost:9001 | پنل مدیریت |
| 🔌 **API GraphQL** | http://localhost:8000/graphql/ | API endpoint |
| 🧪 **Test Checkout** | http://localhost:3000/test-checkout.html | صفحه تست |

## 👤 اطلاعات ورود

### Dashboard Admin
- **ایمیل**: `admin@example.com`
- **رمز عبور**: `admin`

## 📊 وضعیت داده‌ها

- ✅ **محصولات**: 32 محصول
- ✅ **تصاویر**: 43 تصویر محصول
- ✅ **Collections**: 2 (featured-products, summer-picks)
- ✅ **Channels**: 2 (default-channel, channel-pln)
- ✅ **Menus**: 2 (navbar, footer)
- ✅ **Checkouts**: 4 checkout موجود

## 🐳 Docker Services

```bash
# مشاهده وضعیت
docker ps

# باید 8 کانتینر در حال اجرا باشند:
# - production-api-1
# - production-storefront-1
# - production-dashboard-1
# - production-worker-1
# - production-beat-1
# - production-nginx-1
# - production-db-1
# - production-redis-1
```

## 🚀 دستورات مفید

### راه‌اندازی
```bash
cd production
docker compose up -d
```

### توقف
```bash
docker compose down
```

### Restart یک سرویس
```bash
docker compose restart storefront
docker compose restart api
```

### مشاهده لاگ‌ها
```bash
# همه سرویس‌ها
docker compose logs -f

# یک سرویس خاص
docker logs -f production-storefront-1
docker logs -f production-api-1
```

### پاک کردن همه چیز
```bash
docker compose down -v  # حذف volumes هم
```

## 🔧 عیب‌یابی

### مشکل: تصاویر نمایش داده نمی‌شوند
```bash
# بررسی تصاویر در دیتابیس
docker exec production-api-1 python manage.py shell -c "
from saleor.product.models import ProductMedia
print(f'Total images: {ProductMedia.objects.count()}')
"

# اضافه کردن تصاویر نمونه
docker exec production-api-1 python add_product_images.py
```

### مشکل: Checkout کار نمی‌کند
```bash
# بررسی Console مرورگر (F12)
# باید خطای ERR_NAME_NOT_RESOLVED نباشد

# تست API
curl -X POST http://localhost:8000/graphql/ \
  -H "Content-Type: application/json" \
  -d '{"query":"{ shop { name } }"}'
```

### مشکل: API پاسخ نمی‌دهد
```bash
# بررسی وضعیت
docker ps | grep api

# بررسی لاگ‌ها
docker logs production-api-1 --tail 50

# Restart
docker compose restart api
```

### مشکل: CORS Error
```bash
# بررسی تنظیمات
cat production/.env | grep ALLOWED_GRAPHQL_ORIGINS

# باید شامل این باشد:
# ALLOWED_GRAPHQL_ORIGINS=http://localhost:3000,http://localhost:9001
```

## 📁 ساختار فایل‌ها

```
saleor-main/
├── production/
│   ├── docker-compose.yml          # تنظیمات Docker
│   ├── .env                         # متغیرهای محیطی
│   ├── Dockerfile.storefront.dev    # Dockerfile برای storefront
│   ├── nginx.conf                   # تنظیمات Nginx (اختیاری)
│   ├── add_product_images.py        # اسکریپت اضافه کردن تصاویر
│   ├── test-checkout.json           # فایل تست checkout
│   ├── PRODUCT_IMAGES_GUIDE_FA.md   # راهنمای تصاویر
│   ├── CHECKOUT_DEBUG_GUIDE_FA.md   # راهنمای عیب‌یابی checkout
│   └── FINAL_SETUP_SUMMARY_FA.md    # این فایل
│
├── storefront-main/
│   ├── .env.local                   # متغیرهای محیطی storefront
│   ├── next.config.js               # تنظیمات Next.js
│   ├── public/
│   │   ├── test-checkout.html       # صفحه تست checkout
│   │   └── test-api.html            # صفحه تست API
│   └── src/
│       ├── app/
│       │   └── checkout/            # صفحات checkout
│       └── checkout/                # کامپوننت‌های checkout
│
└── saleor/                          # Backend Django
    └── ...
```

## 🎨 ویژگی‌های پیاده شده

### Backend (Saleor)
- ✅ Django + PostgreSQL
- ✅ GraphQL API
- ✅ Celery workers (background tasks)
- ✅ Redis cache
- ✅ Media storage
- ✅ Sample data (products, collections, menus)

### Frontend (Storefront)
- ✅ Next.js 16 (App Router)
- ✅ Turbopack
- ✅ Cache Components
- ✅ TypeScript
- ✅ Tailwind CSS
- ✅ Saleor Auth SDK
- ✅ URQL (GraphQL client)

### Dashboard
- ✅ React-based admin panel
- ✅ Product management
- ✅ Order management
- ✅ Customer management
- ✅ Settings & configuration

## 🔐 نکات امنیتی (برای Production)

⚠️ **هشدار**: تنظیمات فعلی برای محیط development است.

برای production این موارد را تغییر دهید:

### 1. Django Settings
```env
DEBUG=False
SECRET_KEY=<strong-random-key>
ALLOWED_HOSTS=yourdomain.com
```

### 2. RSA Key
```bash
# تولید RSA key
openssl genrsa 2048 | awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' > key.txt

# اضافه کردن به .env
RSA_PRIVATE_KEY=-----BEGIN RSA PRIVATE KEY-----\n...\n-----END RSA PRIVATE KEY-----
```

### 3. Passwords
```env
POSTGRES_PASSWORD=<strong-password>
SALEOR_WEBHOOK_SECRET=<min-32-chars>
REVALIDATE_SECRET=<min-32-chars>
```

### 4. HTTPS
- استفاده از SSL certificate
- تنظیم nginx برای HTTPS
- Force HTTPS redirect

### 5. CORS
```env
# محدود کردن origins
ALLOWED_GRAPHQL_ORIGINS=https://yourdomain.com
```

## 📚 منابع و مستندات

### Saleor
- [Documentation](https://docs.saleor.io/)
- [GitHub](https://github.com/saleor/saleor)
- [Discord Community](https://discord.gg/saleor)

### Next.js
- [Documentation](https://nextjs.org/docs)
- [Learn Next.js](https://nextjs.org/learn)

### GraphQL
- [GraphQL Playground](http://localhost:8000/graphql/)
- [Saleor GraphQL API](https://docs.saleor.io/docs/3.x/api-reference)

## 🎉 تست نهایی

### 1. Storefront
```
http://localhost:3000
```
- [ ] صفحه اصلی لود می‌شود
- [ ] محصولات با تصویر نمایش داده می‌شوند
- [ ] می‌توانید محصول را به سبد خرید اضافه کنید
- [ ] صفحه checkout کار می‌کند

### 2. Dashboard
```
http://localhost:9001
```
- [ ] صفحه login لود می‌شود
- [ ] می‌توانید با admin/admin وارد شوید
- [ ] لیست محصولات نمایش داده می‌شود
- [ ] می‌توانید محصول جدید اضافه کنید

### 3. API
```
http://localhost:8000/graphql/
```
- [ ] GraphQL Playground باز می‌شود
- [ ] می‌توانید query بزنید
- [ ] نتیجه برمی‌گردد

## 🐛 مشکلات شناخته شده

### 1. Menu Footer
- **مشکل**: Menu footer گاهی network error می‌دهد
- **علت**: Cache issue در development mode
- **راه حل**: Refresh صفحه یا restart storefront

### 2. Image Optimization
- **مشکل**: تصاویر optimize نمی‌شوند
- **علت**: `unoptimized: true` در next.config.js
- **راه حل**: برای production از CDN استفاده کنید

### 3. Development Mode
- **مشکل**: کند است
- **علت**: Turbopack در حال compile کردن است
- **راه حل**: صبر کنید تا compile تمام شود

## 📞 پشتیبانی

اگر مشکلی داشتید:

1. **لاگ‌ها را بررسی کنید**
   ```bash
   docker compose logs -f
   ```

2. **Console مرورگر را بررسی کنید**
   ```
   F12 → Console tab
   ```

3. **راهنماهای عیب‌یابی را بخوانید**
   - `PRODUCT_IMAGES_GUIDE_FA.md`
   - `CHECKOUT_DEBUG_GUIDE_FA.md`

4. **Community**
   - [Saleor Discord](https://discord.gg/saleor)
   - [GitHub Issues](https://github.com/saleor/saleor/issues)

---

**موفق باشید! 🚀**

تاریخ: 2026-05-11
نسخه: 1.0
