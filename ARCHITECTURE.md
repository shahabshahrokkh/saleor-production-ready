# معماری پروژه Saleor

## 📦 کامپوننت‌های اصلی

### 1️⃣ API (Backend) - ✅ سورس کد دارید
**مسیر:** `saleor-main/saleor/`
- **زبان:** Python + Django + GraphQL
- **پورت:** 8000
- **قابلیت تغییر:** ✅ کامل

**چی می‌تونید تغییر بدید:**
- ✅ منطق business (models, business logic)
- ✅ GraphQL schema و resolvers
- ✅ دیتابیس (migrations)
- ✅ Webhooks و events
- ✅ Payment gateways
- ✅ Plugins

**مثال تغییرات:**
```python
# saleor/product/models.py
class Product(models.Model):
    name = models.CharField(max_length=250)
    # می‌تونید field جدید اضافه کنید
    custom_field = models.CharField(max_length=100)
```

---

### 2️⃣ Storefront (فروشگاه) - ✅ سورس کد دارید
**مسیر:** `saleor-main/storefront-main/`
- **زبان:** TypeScript + Next.js + React
- **پورت:** 3000
- **قابلیت تغییر:** ✅ کامل

**چی می‌تونید تغییر بدید:**
- ✅ UI و ظاهر (components, pages)
- ✅ استایل (CSS, Tailwind)
- ✅ منطق frontend (React hooks, state management)
- ✅ صفحات جدید اضافه کنید
- ✅ کامپوننت‌های جدید بسازید

**مثال تغییرات:**
```tsx
// storefront-main/src/components/ProductCard.tsx
export function ProductCard({ product }) {
  return (
    <div className="custom-style">
      {/* UI دلخواه خودتون */}
    </div>
  );
}
```

---

### 3️⃣ Dashboard (پنل مدیریت) - ⚠️ حالا سورس کد دارید
**مسیر:** `saleor-main/dashboard-main/`
- **زبان:** TypeScript + React + Vite
- **پورت:** 9001
- **قابلیت تغییر:** ✅ کامل (بعد از clone)

**دو حالت:**

#### حالت A: Image آماده (قبلی)
```yaml
dashboard:
  image: ghcr.io/saleor/saleor-dashboard:3.22
```
- ❌ نمی‌تونید تغییر بدید
- ✅ سریع و آماده

#### حالت B: Build از سورس (جدید - فعلی)
```yaml
dashboard:
  build:
    context: ../dashboard-main
  volumes:
    - ../dashboard-main:/app
```
- ✅ می‌تونید تغییر بدید
- ✅ Hot reload
- ✅ کامل customize

---

## 🏗️ معماری Docker

```
┌─────────────────────────────────────────────────┐
│              Nginx (Port 80)                    │
│  ┌──────────┬──────────────┬─────────────────┐ │
│  │ /        │ /graphql/    │ /dashboard/     │ │
│  │ Storefront│    API       │   Dashboard     │ │
│  └──────────┴──────────────┴─────────────────┘ │
└─────────────────────────────────────────────────┘
         │              │              │
         ▼              ▼              ▼
┌──────────────┐ ┌──────────┐ ┌──────────────┐
│  Storefront  │ │   API    │ │  Dashboard   │
│  (Next.js)   │ │ (Django) │ │   (React)    │
│  Port 3000   │ │ Port 8000│ │  Port 9001   │
└──────────────┘ └──────────┘ └──────────────┘
                      │
         ┌────────────┴────────────┐
         ▼                         ▼
    ┌─────────┐              ┌─────────┐
    │PostgreSQL│              │  Redis  │
    │ Port 5432│              │Port 6379│
    └─────────┘              └─────────┘
```

---

## 🔄 جریان داده

### Browser → API:
```
Browser (localhost:3000)
  → Nginx (localhost:80)
    → API (api:8000)
      → PostgreSQL (db:5432)
```

### Server-Side Rendering:
```
Storefront Container
  → API (api:8000)  ← از hostname داخلی Docker
    → PostgreSQL (db:5432)
```

---

## 📝 چطور تغییرات بدیم؟

### تغییر در API (Backend):
1. فایل‌های Python در `saleor/` رو ویرایش کنید
2. اگر model تغییر دادید: `docker exec production-api-1 python manage.py makemigrations`
3. Migration اجرا کنید: `docker exec production-api-1 python manage.py migrate`
4. API restart کنید: `docker restart production-api-1`

### تغییر در Storefront:
1. فایل‌های TypeScript/React در `storefront-main/src/` رو ویرایش کنید
2. تغییرات **خودکار** اعمال میشه (hot reload) 🔥
3. اگر نشد: `docker restart production-storefront-1`

### تغییر در Dashboard:
1. فایل‌های TypeScript/React در `dashboard-main/src/` رو ویرایش کنید
2. تغییرات **خودکار** اعمال میشه (hot reload) 🔥
3. اگر نشد: `docker restart production-dashboard-1`

---

## 🚀 دستورات مفید

### همه سرویس‌ها:
```powershell
# اجرا
docker compose up -d

# توقف
docker compose down

# مشاهده لاگ‌ها
docker compose logs -f

# Rebuild همه
docker compose up -d --build
```

### یک سرویس خاص:
```powershell
# فقط API
docker compose up -d --build api

# فقط Storefront
docker compose up -d --build storefront

# فقط Dashboard
docker compose up -d --build dashboard
```

### دیباگ:
```powershell
# ورود به container
docker exec -it production-api-1 sh
docker exec -it production-storefront-1 sh
docker exec -it production-dashboard-1 sh

# مشاهده environment variables
docker exec production-api-1 env
docker exec production-storefront-1 env
```

---

## ✅ خلاصه جواب سوالات شما

| کامپوننت | سورس کد | قابل تغییر | زبان | مسیر |
|----------|---------|-----------|------|------|
| **API** | ✅ دارید | ✅ کامل | Python/Django | `saleor/` |
| **Storefront** | ✅ دارید | ✅ کامل | TypeScript/Next.js | `storefront-main/` |
| **Dashboard** | ✅ دارید (جدید) | ✅ کامل | TypeScript/React | `dashboard-main/` |
| **Database** | - | ✅ از طریق API | PostgreSQL | Container |
| **Cache** | - | ⚙️ Config | Redis | Container |

**همه چیز open-source و قابل customize هست!** 🎉
