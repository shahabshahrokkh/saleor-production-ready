# Dashboard Development Guide

## دو حالت برای Dashboard

### حالت 1: استفاده از Image آماده (فعلی)
```yaml
dashboard:
  image: ghcr.io/saleor/saleor-dashboard:3.22  # ← Image آماده
  ports:
    - "9001:80"
```

**مزایا:**
- ✅ سریع و آماده
- ✅ نیازی به build نیست

**معایب:**
- ❌ نمی‌تونید تغییر بدید
- ❌ سورس کد ندارید

---

### حالت 2: Build از سورس کد (برای توسعه)
```yaml
dashboard:
  build:
    context: ../dashboard-main
    dockerfile: ../production/Dockerfile.dashboard.dev
  ports:
    - "9001:9001"
  volumes:
    - ../dashboard-main:/app  # ← تغییرات live اعمال میشه
```

**مزایا:**
- ✅ می‌تونید تغییر بدید
- ✅ تغییرات live اعمال میشه (hot reload)
- ✅ کامل customize

**معایب:**
- ❌ اولین build کمی طول می‌کشه

---

## چطور بین دو حالت سوییچ کنیم؟

### برای استفاده از Image آماده:
در `docker-compose.yml`:
```yaml
dashboard:
  image: ghcr.io/saleor/saleor-dashboard:3.22
  # build: را comment کنید
```

### برای توسعه از سورس:
در `docker-compose.yml`:
```yaml
dashboard:
  # image: را comment کنید
  build:
    context: ../dashboard-main
    dockerfile: ../production/Dockerfile.dashboard.dev
```

---

## دستورات مفید

### Build و اجرای Dashboard از سورس:
```powershell
docker compose up -d --build dashboard
```

### مشاهده لاگ‌ها:
```powershell
docker logs production-dashboard-1 -f
```

### Restart کردن:
```powershell
docker restart production-dashboard-1
```

### توقف و حذف:
```powershell
docker compose down dashboard
```

---

## ساختار فایل‌ها

```
saleor-main/
├── dashboard-main/          ← سورس کد Dashboard (React/TypeScript)
│   ├── src/                 ← کامپوننت‌ها و صفحات
│   ├── package.json
│   └── ...
├── storefront-main/         ← سورس کد Storefront (Next.js)
├── saleor/                  ← سورس کد API (Django/Python)
└── production/
    ├── docker-compose.yml
    ├── Dockerfile.dashboard.dev
    └── Dockerfile.storefront.dev
```

---

## تغییرات در Dashboard

بعد از clone کردن، می‌تونید:

1. **UI تغییر بدید**: فایل‌های React در `dashboard-main/src/`
2. **استایل تغییر بدید**: CSS/Theme files
3. **منطق تغییر بدید**: Business logic در components
4. **GraphQL queries تغییر بدید**: در فایل‌های `.graphql`

تغییرات به صورت **live** اعمال میشه (hot reload) 🔥
