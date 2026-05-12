# راهنمای اضافه کردن تصویر به محصولات

## روش 1: از طریق Dashboard (توصیه می‌شود) ⭐

این ساده‌ترین و بهترین روش برای مدیریت تصاویر محصولات است.

### مراحل:

1. **ورود به داشبورد**
   - آدرس: http://localhost:9001
   - ایمیل: `admin@example.com`
   - رمز عبور: `admin`

2. **رفتن به بخش محصولات**
   - از منوی سمت چپ، روی **Products** کلیک کنید
   - لیست تمام محصولات نمایش داده می‌شود

3. **انتخاب محصول**
   - روی محصول مورد نظر کلیک کنید
   - صفحه ویرایش محصول باز می‌شود

4. **آپلود تصویر**
   - به بخش **Media** بروید (معمولاً در سمت راست صفحه)
   - روی دکمه **Upload** یا **Add Media** کلیک کنید
   - تصاویر را از کامپیوتر خود انتخاب کنید
   - می‌توانید چندین تصویر برای یک محصول اضافه کنید

5. **ذخیره تغییرات**
   - روی دکمه **Save** کلیک کنید
   - تصاویر به محصول اضافه می‌شوند

### نکات مهم:
- ✅ فرمت‌های پشتیبانی شده: JPG, PNG, WEBP, GIF
- ✅ حداکثر حجم فایل: معمولاً 10MB
- ✅ اولین تصویر به عنوان تصویر اصلی محصول نمایش داده می‌شود
- ✅ می‌توانید ترتیب تصاویر را با drag & drop تغییر دهید

---

## روش 2: از طریق GraphQL API

برای توسعه‌دهندگان که می‌خواهند تصاویر را به صورت برنامه‌نویسی اضافه کنند.

### مثال Mutation:

```graphql
mutation {
  productMediaCreate(
    product: "UHJvZHVjdDox"
    image: "https://example.com/image.jpg"
  ) {
    product {
      id
      name
      media {
        url
      }
    }
    errors {
      field
      message
    }
  }
}
```

### با استفاده از File Upload:

```graphql
mutation($file: Upload!) {
  productMediaCreate(
    product: "UHJvZHVjdDox"
    image: $file
  ) {
    product {
      id
      name
    }
    errors {
      field
      message
    }
  }
}
```

---

## روش 3: از طریق Python Script

برای اضافه کردن تصاویر به صورت دسته‌ای (bulk).

### استفاده از اسکریپت موجود:

```bash
# کپی اسکریپت به کانتینر
docker cp add_product_images.py production-api-1:/app/

# اجرای اسکریپت
docker exec production-api-1 python add_product_images.py
```

### نوشتن اسکریپت سفارشی:

```python
from saleor.product.models import Product, ProductMedia
from django.core.files.base import ContentFile
import requests

# دانلود تصویر
response = requests.get("https://example.com/image.jpg")
image_content = response.content

# پیدا کردن محصول
product = Product.objects.get(slug="my-product")

# اضافه کردن تصویر
media = ProductMedia(product=product)
media.image.save("product.jpg", ContentFile(image_content), save=True)
```

---

## روش 4: آپلود مستقیم فایل به Media Directory

برای محیط توسعه (Development).

### مراحل:

1. **کپی تصاویر به پوشه media**
   ```bash
   docker cp /path/to/images production-api-1:/app/media/products/
   ```

2. **ثبت تصاویر در دیتابیس**
   ```python
   from saleor.product.models import Product, ProductMedia

   product = Product.objects.get(slug="my-product")
   media = ProductMedia(product=product)
   media.image = "products/my-image.jpg"
   media.save()
   ```

---

## مدیریت تصاویر

### تغییر ترتیب تصاویر:
- در Dashboard، در بخش Media، تصاویر را drag & drop کنید
- اولین تصویر به عنوان تصویر اصلی نمایش داده می‌شود

### حذف تصویر:
- در Dashboard، روی آیکون سطل زباله کنار تصویر کلیک کنید

### تنظیم Alt Text (برای SEO):
- روی تصویر کلیک کنید
- در فیلد **Alt Text** توضیحات تصویر را وارد کنید
- این برای SEO و دسترسی‌پذیری مهم است

---

## بهینه‌سازی تصاویر

### توصیه‌ها:
- 📐 **ابعاد**: حداقل 800x800 پیکسل برای تصاویر محصول
- 🗜️ **فشرده‌سازی**: از ابزارهایی مثل TinyPNG استفاده کنید
- 🎨 **فرمت**: WEBP برای بهترین کیفیت و حجم کمتر
- 📱 **Responsive**: Saleor به صورت خودکار تصاویر را در سایزهای مختلف تولید می‌کند

### ابزارهای پیشنهادی:
- [TinyPNG](https://tinypng.com/) - فشرده‌سازی آنلاین
- [Squoosh](https://squoosh.app/) - تبدیل به WEBP
- [ImageOptim](https://imageoptim.com/) - بهینه‌سازی دسته‌ای

---

## عیب‌یابی

### تصویر نمایش داده نمی‌شود:
1. بررسی کنید که تصویر در Dashboard نمایش داده می‌شود
2. Cache مرورگر را پاک کنید (Ctrl+Shift+R)
3. Storefront را restart کنید:
   ```bash
   docker compose restart storefront
   ```

### خطای آپلود:
1. بررسی کنید حجم فایل کمتر از حد مجاز باشد
2. فرمت فایل صحیح باشد (JPG, PNG, WEBP)
3. دسترسی‌های پوشه media را بررسی کنید

### تصویر کیفیت پایین دارد:
1. تصویر با کیفیت بالاتر آپلود کنید (حداقل 800x800)
2. از فرمت WEBP استفاده کنید
3. تنظیمات thumbnail در Django settings را بررسی کنید

---

## منابع بیشتر

- [Saleor Documentation - Products](https://docs.saleor.io/docs/3.x/developer/products)
- [GraphQL API - Product Media](https://docs.saleor.io/docs/3.x/api-reference/products/mutations/product-media-create)
- [Dashboard User Guide](https://docs.saleor.io/docs/3.x/dashboard/catalog/products)

---

## تماس و پشتیبانی

برای سوالات بیشتر:
- 📧 ایمیل: support@example.com
- 💬 Discord: [Saleor Community](https://discord.gg/saleor)
- 📚 مستندات: https://docs.saleor.io
