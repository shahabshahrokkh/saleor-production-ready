# خلاصه رفع مشکل Checkout

## مشکل اصلی

مشکل اصلی این بود که Saleor Storefront از یک URL برای هم server-side (SSR) و هم client-side (browser) استفاده می‌کرد:
- `NEXT_PUBLIC_SALEOR_API_URL=http://localhost:8000/graphql/`

این باعث می‌شد:
1. **Server-side (داخل Docker container)**: `localhost` به خود container اشاره می‌کرد نه به API، پس نمی‌توانست به API متصل شود
2. **Client-side (مرورگر)**: `localhost` به کامپیوتر شما اشاره می‌کرد که درست بود

## راه حل پیاده‌سازی شده

### 1. ایجاد Helper Function

فایل جدید: `storefront-main/src/lib/saleor-api-url.ts`

این function بسته به محیط اجرا (server یا client)، URL مناسب را برمی‌گرداند:
- **Server-side**: از `SALEOR_API_URL` استفاده می‌کند (اسم service در Docker network)
- **Client-side**: از `NEXT_PUBLIC_SALEOR_API_URL` استفاده می‌کند (localhost برای دسترسی مستقیم)

### 2. تنظیم Environment Variables

در `docker-compose.yml`:
```yaml
environment:
  # Client-side (browser) needs localhost
  NEXT_PUBLIC_SALEOR_API_URL: http://localhost:8000/graphql/
  NEXT_PUBLIC_STOREFRONT_URL: http://localhost:3000
  NEXT_PUBLIC_DEFAULT_CHANNEL: default-channel
  # Server-side (SSR/build) needs Docker service name
  SALEOR_API_URL: http://api:8000/graphql/
```

### 3. آپدیت کدهای استفاده‌کننده

فایل‌های زیر آپدیت شدند تا از `getSaleorApiUrl()` استفاده کنند:
- `src/lib/graphql.ts` (2 مورد)
- `src/lib/auth/server.ts`

## نتیجه

✅ **Server-side**: حالا می‌تواند به API متصل شود و داده‌ها را fetch کند
✅ **Client-side**: همچنان می‌تواند مستقیماً به API متصل شود
✅ **Checkout**: باید حالا کار کند چون هم SSR و هم client-side requests درست کار می‌کنند

## تست

لطفاً موارد زیر را تست کنید:

1. **صفحه اصلی**: http://localhost:3000
   - باید محصولات نمایش داده شوند
   - تصاویر باید load شوند

2. **صفحه محصول**: روی یک محصول کلیک کنید
   - جزئیات محصول باید نمایش داده شود

3. **Checkout**: محصولی را به سبد خرید اضافه کنید و به checkout بروید
   - باید بدون خطای `ERR_NAME_NOT_RESOLVED` کار کند
   - اطلاعات checkout باید نمایش داده شود

## فایل‌های تغییر یافته

1. `production/docker-compose.yml` - اضافه شدن `SALEOR_API_URL`
2. `storefront-main/src/lib/saleor-api-url.ts` - فایل جدید
3. `storefront-main/src/lib/graphql.ts` - استفاده از helper function
4. `storefront-main/src/lib/auth/server.ts` - استفاده از helper function

## لاگ‌های موفقیت‌آمیز

```
[Server] Using Saleor API URL: http://api:8000/graphql/
GET /default-channel 200 in 1798ms
```

دیگر خطای "Failed to connect to Saleor API" نداریم! 🎉
