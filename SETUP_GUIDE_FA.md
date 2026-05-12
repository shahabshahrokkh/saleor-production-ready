# راهنمای راه‌اندازی کامل Saleor Backend + Storefront

این راهنما شامل تمام مراحل لازم برای راه‌اندازی بک‌اند Saleor با دیتای نمونه و اتصال storefront به آن است.

## پیش‌نیازها

قبل از شروع، مطمئن شوید که موارد زیر نصب شده‌اند:

- Python 3.12+
- Node.js 20+ (برای storefront)
- pnpm (برای storefront)
- PostgreSQL
- Redis
- Virtual environment فعال شده

## بخش 1: راه‌اندازی Backend و دیتای نمونه

### 1.1 بررسی وضعیت محیط

```bash
# فعال‌سازی virtual environment
source .venv/bin/activate  # در Linux/Mac
# یا
.venv\Scripts\activate  # در Windows

# بررسی نصب وابستگی‌ها
python --version
pip list | grep Django
```

### 1.2 تنظیم متغیرهای محیطی

فایل `.env` در ریشه پروژه موجود است. محتوای فعلی:

```env
CACHE_URL=redis://localhost:6379/0
CELERY_BROKER_URL=redis://localhost:6379/1
DEFAULT_FROM_EMAIL=noreply@example.com
EMAIL_URL=smtp://localhost:1025
SECRET_KEY=changeme
HTTP_IP_FILTER_ALLOW_LOOPBACK_IPS=True
DASHBOARD_URL=http://localhost:9000/
```

**نکته مهم:** اگر از Docker استفاده نمی‌کنید، باید PostgreSQL و Redis را به صورت محلی راه‌اندازی کنید و متغیرهای زیر را اضافه کنید:

```env
DATABASE_URL=postgres://user:password@localhost:5432/saleor
```

### 1.3 اجرای Migrations

```bash
# اجرای migrations برای ایجاد جداول دیتابیس
python manage.py migrate
```

### 1.4 ایجاد دیتای نمونه (Sample Data)

Saleor یک دستور مدیریتی قدرتمند به نام `populatedb` دارد که دیتای نمونه کامل ایجاد می‌کند:

```bash
# ایجاد دیتای نمونه با تصاویر + حساب superuser
python manage.py populatedb --createsuperuser

# یا بدون تصاویر (سریع‌تر)
python manage.py populatedb --createsuperuser --withoutimages
```

**پارامترهای مفید:**
- `--createsuperuser`: ایجاد حساب ادمین (پیشنهادی)
- `--superuser_password`: رمز عبور ادمین (پیش‌فرض: `admin`)
- `--user_password`: رمز عبور کاربران نمونه (پیش‌فرض: `password`)
- `--staff_password`: رمز عبور کارمندان (پیش‌فرض: `password`)
- `--withoutimages`: بدون ایجاد تصاویر محصولات
- `--skipsequencereset`: عدم reset کردن sequence های SQL

**اطلاعات ورود پیش‌فرض:**
- ایمیل ادمین: `admin@example.com`
- رمز عبور: `admin` (یا مقداری که با `--superuser_password` تعیین کردید)

### 1.5 راه‌اندازی سرور Backend

```bash
# راه‌اندازی سرور توسعه Django
python manage.py runserver 0.0.0.0:8000
```

سرور روی آدرس زیر در دسترس خواهد بود:
- **GraphQL API:** http://localhost:8000/graphql/
- **GraphQL Playground:** http://localhost:8000/graphql/ (در مرورگر)

### 1.6 تست API

می‌توانید با باز کردن http://localhost:8000/graphql/ در مرورگر، GraphQL Playground را ببینید و query های زیر را تست کنید:

```graphql
# لیست محصولات
query {
  products(first: 10, channel: "default-channel") {
    edges {
      node {
        id
        name
        slug
        thumbnail {
          url
        }
      }
    }
  }
}

# لیست کانال‌ها
query {
  channels {
    id
    name
    slug
    currencyCode
  }
}
```

## بخش 2: راه‌اندازی Storefront

### 2.1 بررسی ساختار Storefront

Storefront در پوشه `storefront-main` موجود است و از Next.js 16 استفاده می‌کند.

### 2.2 تنظیم متغیرهای محیطی Storefront

فایل `.env.local` در `storefront-main` موجود است:

```env
NEXT_PUBLIC_SALEOR_API_URL=http://localhost:8000/graphql/
NEXT_PUBLIC_STOREFRONT_URL=http://localhost:3000
NEXT_PUBLIC_DEFAULT_CHANNEL=default-channel
```

**نکات مهم:**
- `NEXT_PUBLIC_SALEOR_API_URL`: باید به GraphQL endpoint بک‌اند شما اشاره کند
- `NEXT_PUBLIC_DEFAULT_CHANNEL`: slug کانال پیش‌فرض (معمولاً `default-channel`)
- URL ها باید با `/` در انتها باشند

### 2.3 نصب وابستگی‌های Storefront

```bash
cd storefront-main

# نصب pnpm (اگر نصب نیست)
npm install -g pnpm

# نصب وابستگی‌ها
pnpm install
```

### 2.4 تولید TypeScript Types از GraphQL

```bash
# تولید types از schema
pnpm run generate:all
```

این دستور:
- Schema های GraphQL را از بک‌اند دریافت می‌کند
- TypeScript types را تولید می‌کند
- فایل‌های generated در `src/gql/` قرار می‌گیرند

### 2.5 اجرای Storefront

```bash
# اجرای سرور توسعه
pnpm dev
```

Storefront روی آدرس زیر در دسترس خواهد بود:
- **Storefront:** http://localhost:3000

## بخش 3: تست و بررسی نهایی

### 3.1 چک‌لیست تست

- [ ] Backend روی http://localhost:8000 در حال اجراست
- [ ] GraphQL Playground در http://localhost:8000/graphql/ کار می‌کند
- [ ] Storefront روی http://localhost:3000 در حال اجراست
- [ ] محصولات در صفحه اصلی storefront نمایش داده می‌شوند
- [ ] می‌توانید به صفحه جزئیات محصول بروید
- [ ] می‌توانید محصول به سبد خرید اضافه کنید
- [ ] می‌توانید با `admin@example.com` / `admin` وارد Dashboard شوید

### 3.2 آدرس‌های نهایی

| سرویس | آدرس | توضیحات |
|-------|------|---------|
| **Backend API** | http://localhost:8000/graphql/ | GraphQL endpoint |
| **GraphQL Playground** | http://localhost:8000/graphql/ | تست API در مرورگر |
| **Storefront** | http://localhost:3000 | فروشگاه مشتری |
| **Dashboard** | http://localhost:9000 | پنل مدیریت (نیاز به نصب جداگانه) |

### 3.3 اطلاعات ورود

**حساب Superuser:**
- ایمیل: `admin@example.com`
- رمز عبور: `admin`

**کاربران نمونه:**
- رمز عبور: `password`
- تعداد: 20 کاربر با ایمیل‌های تصادفی

## بخش 4: عیب‌یابی رایج

### مشکل: Storefront نمی‌تواند به Backend متصل شود

**راه‌حل:**
1. مطمئن شوید Backend در حال اجراست
2. بررسی کنید `NEXT_PUBLIC_SALEOR_API_URL` صحیح است
3. CORS را در Backend بررسی کنید (باید `localhost:3000` مجاز باشد)

### مشکل: محصولات در Storefront نمایش داده نمی‌شوند

**راه‌حل:**
1. بررسی کنید `populatedb` با موفقیت اجرا شده
2. در GraphQL Playground query محصولات را تست کنید
3. مطمئن شوید `NEXT_PUBLIC_DEFAULT_CHANNEL` با slug کانال در Saleor مطابقت دارد

### مشکل: خطای Database Connection

**راه‌حل:**
1. مطمئن شوید PostgreSQL در حال اجراست
2. بررسی کنید `DATABASE_URL` در `.env` صحیح است
3. دسترسی‌های دیتابیس را بررسی کنید

### مشکل: خطای Redis Connection

**راه‌حل:**
1. مطمئن شوید Redis در حال اجراست: `redis-cli ping`
2. بررسی کنید `CACHE_URL` و `CELERY_BROKER_URL` صحیح هستند

## بخش 5: دستورات مفید

### Backend Commands

```bash
# پاک کردن دیتابیس
python manage.py cleardb

# پاک کردن فقط سفارشات
python manage.py clearorders

# ایجاد superuser دستی
python manage.py createsuperuser

# بروزرسانی search indexes
python manage.py update_search_indexes
```

### Storefront Commands

```bash
# Build برای production
pnpm build

# اجرای production build
pnpm start

# Lint کردن کد
pnpm lint

# اجرای تست‌ها
pnpm test:run
```

## بخش 6: مراحل بعدی

### نصب Dashboard (اختیاری)

اگر می‌خواهید Dashboard مدیریتی Saleor را هم نصب کنید:

```bash
# Clone کردن Dashboard
git clone https://github.com/saleor/saleor-dashboard.git
cd saleor-dashboard

# نصب و اجرا
npm install
npm start
```

Dashboard روی http://localhost:9000 اجرا می‌شود.

### تنظیم Webhooks برای Cache Invalidation

برای بروزرسانی خودکار cache در storefront:

1. در Saleor Dashboard → Configuration → Webhooks
2. ایجاد webhook جدید با URL: `http://localhost:3000/api/revalidate`
3. Subscribe به events: `PRODUCT_UPDATED`, `CATEGORY_UPDATED`, etc.
4. تنظیم `SALEOR_WEBHOOK_SECRET` در `.env.local` storefront

### تنظیم Payment Gateway

برای فعال‌سازی پرداخت:

1. نصب Saleor Payment App (Stripe یا Adyen)
2. تنظیم credentials در Dashboard
3. فعال‌سازی در کانال مورد نظر

## منابع اضافی

- **مستندات Saleor:** https://docs.saleor.io
- **مستندات Storefront:** https://github.com/saleor/storefront
- **Discord Community:** https://saleor.io/discord
- **GraphQL API Reference:** https://docs.saleor.io/api-reference

---

## خلاصه دستورات سریع

```bash
# Backend
source .venv/bin/activate
python manage.py migrate
python manage.py populatedb --createsuperuser
python manage.py runserver 0.0.0.0:8000

# Storefront (در ترمینال جدید)
cd storefront-main
pnpm install
pnpm run generate:all
pnpm dev
```

**آدرس‌های نهایی:**
- Backend API: http://localhost:8000/graphql/
- Storefront: http://localhost:3000
- Login: admin@example.com / admin

موفق باشید! 🚀
