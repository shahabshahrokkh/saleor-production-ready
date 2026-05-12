#!/usr/bin/env python
"""
اسکریپت برای اضافه کردن تصاویر نمونه به محصولات
"""
import os
import django

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "saleor.settings")
django.setup()

from django.core.files.base import ContentFile
from saleor.product.models import Product, ProductMedia
import requests

# لیست URLهای تصاویر نمونه از Unsplash (رایگان)
SAMPLE_IMAGES = [
    "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800",  # ساعت
    "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800",  # هدفون
    "https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=800",  # عینک
    "https://images.unsplash.com/photo-1491553895911-0055eca6402d?w=800",  # کفش
    "https://images.unsplash.com/photo-1560343090-f0409e92791a?w=800",  # تیشرت
    "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800",  # کفش ورزشی
    "https://images.unsplash.com/photo-1585386959984-a4155224a1ad?w=800",  # کیف
    "https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=800",  # دفترچه
]

def download_image(url):
    """دانلود تصویر از URL"""
    try:
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            return response.content
    except Exception as e:
        print(f"خطا در دانلود تصویر {url}: {e}")
    return None

def add_images_to_products():
    """اضافه کردن تصاویر به محصولات"""
    products = Product.objects.all()[:len(SAMPLE_IMAGES)]

    print(f"در حال اضافه کردن تصویر به {products.count()} محصول...")

    for idx, product in enumerate(products):
        # حذف تصاویر قبلی
        ProductMedia.objects.filter(product=product).delete()

        # دانلود و اضافه کردن تصویر جدید
        image_url = SAMPLE_IMAGES[idx % len(SAMPLE_IMAGES)]
        print(f"دانلود تصویر برای {product.name}...")

        image_content = download_image(image_url)
        if image_content:
            media = ProductMedia(product=product)
            media.image.save(
                f"product_{product.id}.jpg",
                ContentFile(image_content),
                save=True
            )
            print(f"✓ تصویر برای {product.name} اضافه شد")
        else:
            print(f"✗ خطا در اضافه کردن تصویر برای {product.name}")

    print("\nتمام!")

if __name__ == "__main__":
    add_images_to_products()
