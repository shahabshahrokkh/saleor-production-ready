# رفع مشکل CORS - خلاصه نهایی

## مشکل

خطای CORS:
```
Access to fetch at 'http://localhost:8000/graphql/' from origin 'http://localhost'
has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present
```

## علت

Saleor API فقط اجازه می‌داد که درخواست‌ها از `http://localhost:3000` و `http://localhost:9001` بیان، اما مرورگر شما از `http://localhost` (بدون port) داشت request میزد.

## راه حل

`http://localhost` را به لیست `ALLOWED_GRAPHQL_ORIGINS` در فایل `.env` اضافه کردم:

```env
ALLOWED_GRAPHQL_ORIGINS=http://localhost:3000,http://localhost:9001,http://localhost
```

## تغییرات انجام شده

1. ✅ آپدیت `production/.env` - اضافه شدن `http://localhost` به CORS origins
2. ✅ Restart API container - اعمال تنظیمات جدید

## تست کنید

لطفاً موارد زیر را تست کنید:

### 1. صفحه اصلی
- URL: http://localhost:3000
- باید محصولات و تصاویر نمایش داده شوند ✅

### 2. Checkout
- محصولی را به سبد خرید اضافه کنید
- روی "Checkout" کلیک کنید
- **نباید** خطای `ERR_NAME_NOT_RESOLVED` یا CORS ببینید
- اطلاعات checkout باید نمایش داده شود

### 3. Console مرورگر
- F12 را بزنید و به tab Console بروید
- **نباید** خطای قرمز CORS ببینید
- ممکن است warning های زرد ببینید که مشکلی نیست

## اگر هنوز مشکل دارید

1. **کش مرورگر را پاک کنید**:
   - Chrome/Edge: Ctrl+Shift+Delete → Clear browsing data
   - یا Incognito/Private mode استفاده کنید

2. **Hard refresh**:
   - Ctrl+F5 یا Ctrl+Shift+R

3. **Console را چک کنید**:
   - F12 → Console tab
   - اگر خطا دیدید، متن کامل خطا را برایم بفرستید

## خلاصه تمام تغییرات برای رفع Checkout

### مشکل 1: ERR_NAME_NOT_RESOLVED ✅ حل شد
- **علت**: Storefront از `http://api:8000` استفاده می‌کرد که فقط در Docker network کار می‌کنه
- **راه حل**: تفکیک URL برای server-side و client-side
  - Server-side: `http://api:8000/graphql/` (Docker network)
  - Client-side: `http://localhost:8000/graphql/` (مرورگر)

### مشکل 2: CORS Error ✅ حل شد
- **علت**: API اجازه نمی‌داد درخواست از `http://localhost` بیاد
- **راه حل**: اضافه کردن `http://localhost` به `ALLOWED_GRAPHQL_ORIGINS`

## فایل‌های تغییر یافته

1. `production/.env` - تنظیمات CORS
2. `storefront-main/src/lib/saleor-api-url.ts` - helper function برای انتخاب URL
3. `storefront-main/src/lib/graphql.ts` - استفاده از helper
4. `storefront-main/src/lib/auth/server.ts` - استفاده از helper
5. `production/docker-compose.yml` - اضافه شدن `SALEOR_API_URL`

## وضعیت فعلی

✅ Server-side: از `http://api:8000/graphql/` استفاده می‌کنه
✅ Client-side: از `http://localhost:8000/graphql/` استفاده می‌کنه
✅ CORS: `http://localhost` اجازه داره
✅ API: در حال اجرا و آماده دریافت درخواست

**همه چیز آماده است! لطفاً checkout را تست کنید.** 🎉
