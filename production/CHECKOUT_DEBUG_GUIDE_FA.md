# راهنمای عیب‌یابی Checkout

## وضعیت فعلی

✅ **API**: در حال اجرا و پاسخگو
✅ **Checkout در دیتابیس**: 4 checkout موجود
✅ **Checkout Query**: از طریق API به درستی کار می‌کند
✅ **Storefront**: صفحه checkout با کد 200 لود می‌شود

❓ **مشکل**: Checkout در مرورگر به درستی نمایش داده نمی‌شود

## مراحل عیب‌یابی

### مرحله 1: تست API از طریق مرورگر

1. **باز کردن صفحه تست**:
   ```
   http://localhost:3000/test-checkout.html
   ```

2. **کلیک روی "Test Checkout Query"**
   - اگر موفق بود: API و CORS به درستی کار می‌کنند
   - اگر خطا داد: مشکل CORS یا network است

3. **کلیک روی "Test Simple Query"**
   - تست ساده‌تر برای بررسی اتصال پایه

### مرحله 2: بررسی Console مرورگر

1. **باز کردن Developer Tools**:
   ```
   F12 یا Ctrl+Shift+I
   ```

2. **رفتن به tab Console**

3. **باز کردن صفحه checkout**:
   ```
   http://localhost:3000/checkout?checkout=Q2hlY2tvdXQ6ODY2MTcwYjQtMDJlYy00NGIwLTk0YTAtZmJkOGE5ZmU5ODJl
   ```

4. **بررسی خطاها**:
   - ❌ **CORS Error**: مشکل در تنظیمات CORS
   - ❌ **Network Error**: مشکل در اتصال به API
   - ❌ **401/403**: مشکل authentication
   - ❌ **GraphQL Error**: مشکل در query یا data

### مرحله 3: بررسی Network Tab

1. **رفتن به tab Network** در Developer Tools

2. **Refresh صفحه checkout**

3. **فیلتر کردن درخواست‌های GraphQL**:
   - جستجو برای: `graphql`

4. **کلیک روی درخواست checkout**:
   - بررسی **Request Headers**
   - بررسی **Response**
   - بررسی **Status Code**

### مرحله 4: بررسی لاگ‌های Storefront

```bash
docker logs production-storefront-1 --tail 100 | grep -i "checkout\|error"
```

**چیزهایی که باید دنبال کنید**:
- ❌ `Failed to fetch`
- ❌ `Network error`
- ❌ `GraphQL error`
- ✅ `200` status codes

### مرحله 5: بررسی لاگ‌های API

```bash
docker logs production-api-1 --tail 100 | grep -i "checkout\|error"
```

**چیزهایی که باید دنبال کنید**:
- ❌ `DisallowedHost`
- ❌ `CORS`
- ❌ `Permission denied`
- ✅ درخواست‌های موفق

## مشکلات رایج و راه حل‌ها

### 1. خطای CORS

**علائم**:
```
Access to fetch at 'http://localhost:8000/graphql/' from origin 'http://localhost:3000'
has been blocked by CORS policy
```

**راه حل**:
```bash
# بررسی ALLOWED_GRAPHQL_ORIGINS در .env
cat production/.env | grep ALLOWED_GRAPHQL_ORIGINS

# باید شامل این باشد:
ALLOWED_GRAPHQL_ORIGINS=http://localhost:3000,http://localhost:9001
```

اگر نیست، اضافه کنید و API را restart کنید:
```bash
docker compose restart api
```

### 2. خطای Network / Connection Refused

**علائم**:
```
Failed to fetch
net::ERR_CONNECTION_REFUSED
```

**راه حل**:
```bash
# بررسی وضعیت API
docker ps | grep api

# اگر متوقف شده، راه‌اندازی کنید
docker compose up -d api

# بررسی لاگ‌ها
docker logs production-api-1 --tail 50
```

### 3. Checkout خالی است

**علائم**:
- صفحه checkout لود می‌شود اما محصولی نمایش داده نمی‌شود

**راه حل**:
```bash
# بررسی checkout در دیتابیس
docker exec production-api-1 python manage.py shell -c "
from saleor.checkout.models import Checkout
import base64
checkout_id = 'Q2hlY2tvdXQ6ODY2MTcwYjQtMDJlYy00NGIwLTk0YTAtZmJkOGE5ZmU5ODJl'
decoded = base64.b64decode(checkout_id).decode()
uuid = decoded.split(':')[1]
checkout = Checkout.objects.filter(pk=uuid).first()
print(f'Checkout exists: {checkout is not None}')
print(f'Lines count: {checkout.lines.count() if checkout else 0}')
if checkout:
    for line in checkout.lines.all():
        print(f'  - {line.variant.name}: {line.quantity}')
"
```

### 4. خطای Authentication

**علائم**:
```
401 Unauthorized
403 Forbidden
```

**راه حل**:
- Checkout نیازی به authentication ندارد
- اگر این خطا را می‌بینید، مشکل در تنظیمات permissions است

```bash
# بررسی تنظیمات
docker exec production-api-1 python manage.py shell -c "
from django.conf import settings
print(f'DEBUG: {settings.DEBUG}')
print(f'ALLOWED_HOSTS: {settings.ALLOWED_HOSTS}')
"
```

### 5. GraphQL Query Error

**علائم**:
```json
{
  "errors": [
    {
      "message": "...",
      "extensions": { "code": "..." }
    }
  ]
}
```

**راه حل**:
- بررسی دقیق پیام خطا
- تست query با GraphQL Playground: `http://localhost:8000/graphql/`

## تست دستی Checkout

### تست 1: ایجاد Checkout جدید

```bash
# از طریق GraphQL
curl -X POST http://localhost:8000/graphql/ \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation { checkoutCreate(input: { channel: \"default-channel\", lines: [{ quantity: 1, variantId: \"UHJvZHVjdFZhcmlhbnQ6MzI1\" }] }) { checkout { id } errors { field message } } }"
  }'
```

### تست 2: دریافت Checkout

```bash
curl -X POST http://localhost:8000/graphql/ \
  -H "Content-Type: application/json" \
  -d '{
    "query": "query { checkout(id: \"Q2hlY2tvdXQ6ODY2MTcwYjQtMDJlYy00NGIwLTk0YTAtZmJkOGE5ZmU5ODJl\") { id email lines { id quantity variant { id name } } } }"
  }'
```

### تست 3: اضافه کردن محصول به Checkout

```bash
curl -X POST http://localhost:8000/graphql/ \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation { checkoutLinesAdd(id: \"Q2hlY2tvdXQ6ODY2MTcwYjQtMDJlYy00NGIwLTk0YTAtZmJkOGE5ZmU5ODJl\", lines: [{ quantity: 1, variantId: \"UHJvZHVjdFZhcmlhbnQ6MzI2\" }]) { checkout { id lines { id } } errors { field message } } }"
  }'
```

## بررسی تنظیمات

### 1. Environment Variables

```bash
# Storefront
docker exec production-storefront-1 env | grep NEXT_PUBLIC

# باید نمایش دهد:
# NEXT_PUBLIC_SALEOR_API_URL=http://api:8000/graphql/
# NEXT_PUBLIC_STOREFRONT_URL=http://localhost:3000
# NEXT_PUBLIC_DEFAULT_CHANNEL=default-channel
```

### 2. CORS Headers

```bash
# تست CORS از مرورگر
# باز کردن Console و اجرای:
fetch('http://localhost:8000/graphql/', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ query: '{ shop { name } }' })
})
.then(r => r.json())
.then(console.log)
.catch(console.error)
```

### 3. Network Connectivity

```bash
# از داخل storefront به API
docker exec production-storefront-1 wget -O- http://api:8000/graphql/ \
  --post-data='{"query":"{ shop { name } }"}' \
  --header='Content-Type: application/json' 2>&1
```

## راه حل‌های پیشرفته

### 1. پاک کردن Cache

```bash
# پاک کردن cache مرورگر
# Ctrl+Shift+Delete

# پاک کردن cache Next.js
docker exec production-storefront-1 rm -rf /app/.next/cache

# Restart storefront
docker compose restart storefront
```

### 2. Rebuild Storefront

```bash
# اگر مشکل ادامه دارد
docker compose build --no-cache storefront
docker compose up -d storefront
```

### 3. بررسی Saleor Auth SDK

```bash
# بررسی نسخه auth SDK
docker exec production-storefront-1 cat /app/package.json | grep "@saleor/auth-sdk"
```

## لاگ‌های مفید

### Real-time Logs

```bash
# Storefront
docker logs -f production-storefront-1

# API
docker logs -f production-api-1

# همه سرویس‌ها
docker compose logs -f
```

### فیلتر شده

```bash
# فقط خطاها
docker logs production-storefront-1 2>&1 | grep -i error

# فقط checkout
docker logs production-storefront-1 2>&1 | grep -i checkout

# فقط GraphQL
docker logs production-storefront-1 2>&1 | grep -i graphql
```

## چک لیست نهایی

قبل از گزارش مشکل، این موارد را بررسی کنید:

- [ ] API در حال اجرا است (`docker ps`)
- [ ] Storefront در حال اجرا است (`docker ps`)
- [ ] CORS به درستی تنظیم شده (`ALLOWED_GRAPHQL_ORIGINS`)
- [ ] Environment variables صحیح هستند
- [ ] Checkout در دیتابیس وجود دارد
- [ ] Console مرورگر را بررسی کرده‌اید
- [ ] Network tab را بررسی کرده‌اید
- [ ] لاگ‌های API و Storefront را بررسی کرده‌اید
- [ ] صفحه تست (`/test-checkout.html`) را امتحان کرده‌اید

## اطلاعات تماس و منابع

- [Saleor Documentation](https://docs.saleor.io/)
- [Saleor Storefront GitHub](https://github.com/saleor/storefront)
- [Saleor Discord](https://discord.gg/saleor)

---

**نکته**: این راهنما برای محیط development است. برای production، تنظیمات امنیتی بیشتری نیاز است.
