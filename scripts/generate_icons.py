from PIL import Image
import os
import json

# -------- CONFIG --------
SOURCE_ICON = "assets/icons/abideverse_splash_logo_1024x1024.png"   # Your input PNG (1024x1024 recommended)
OUTPUT_DIR = "generated_icons"

# iOS app icon definitions for Contents.json
IOS_ICON_SPECS = [
    {"size": "20x20", "idiom": "iphone", "scale": "2x", "pixels": 40},
    {"size": "20x20", "idiom": "iphone", "scale": "3x", "pixels": 60},

    {"size": "29x29", "idiom": "iphone", "scale": "2x", "pixels": 58},
    {"size": "29x29", "idiom": "iphone", "scale": "3x", "pixels": 87},

    {"size": "40x40", "idiom": "iphone", "scale": "2x", "pixels": 80},
    {"size": "40x40", "idiom": "iphone", "scale": "3x", "pixels": 120},

    {"size": "60x60", "idiom": "iphone", "scale": "2x", "pixels": 120},
    {"size": "60x60", "idiom": "iphone", "scale": "3x", "pixels": 180},

    {"size": "20x20", "idiom": "ipad", "scale": "1x", "pixels": 20},
    {"size": "20x20", "idiom": "ipad", "scale": "2x", "pixels": 40},

    {"size": "29x29", "idiom": "ipad", "scale": "1x", "pixels": 29},
    {"size": "29x29", "idiom": "ipad", "scale": "2x", "pixels": 58},

    {"size": "40x40", "idiom": "ipad", "scale": "1x", "pixels": 40},
    {"size": "40x40", "idiom": "ipad", "scale": "2x", "pixels": 80},

    {"size": "76x76", "idiom": "ipad", "scale": "1x", "pixels": 76},
    {"size": "76x76", "idiom": "ipad", "scale": "2x", "pixels": 152},

    {"size": "83.5x83.5", "idiom": "ipad", "scale": "2x", "pixels": 167},

    {"size": "1024x1024", "idiom": "ios-marketing", "scale": "1x", "pixels": 1024}
]

ANDROID_SIZES = [
    (48,  "android/mipmap-mdpi/ic_launcher.png"),
    (72,  "android/mipmap-hdpi/ic_launcher.png"),
    (96,  "android/mipmap-xhdpi/ic_launcher.png"),
    (144, "android/mipmap-xxhdpi/ic_launcher.png"),
    (192, "android/mipmap-xxxhdpi/ic_launcher.png"),
    (512, "android/ic_playstore_512x512.png"),
]

WEB_SIZES = [
    (16, "web/favicon-16x16.png"),
    (32, "web/favicon-32x32.png"),
    (48, "web/favicon-48x48.png"),

    (64, "web/icons/icon-64.png"),
    (128, "web/icons/icon-128.png"),
    (192, "web/icons/icon-192.png"),
    (256, "web/icons/icon-256.png"),
    (512, "web/icons/icon-512.png"),
]

# PWA manifest for Flutter web
MANIFEST = {
  "name": "AbideVerse 常在主裡",
  "short_name": "AbideVerse 常在主裡",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#ffffff",
  "description": "A Flutter Application",
  "icons": [
    {"src": "icons/icon-192.png", "sizes": "192x192", "type": "image/png"},
    {"src": "icons/icon-512.png", "sizes": "512x512", "type": "image/png"}
  ]
}


# ------------- HELPERS -------------

def create_icon(size, path):
    """Create a resized PNG icon."""
    os.makedirs(os.path.dirname(os.path.join(OUTPUT_DIR, path)), exist_ok=True)
    img = Image.open(SOURCE_ICON).convert("RGBA").resize((size, size), Image.LANCZOS)
    img.save(os.path.join(OUTPUT_DIR, path))


def generate_ios_contents_json():
    """Generate iOS Contents.json for AppIcon.appiconset."""
    ios_path = os.path.join(OUTPUT_DIR, "ios/AppIcon.appiconset")
    os.makedirs(ios_path, exist_ok=True)

    contents = {"images": [], "info": {"version": 1, "author": "xcode"}}

    for icon in IOS_ICON_SPECS:
        filename = f"icon-{icon['pixels']}.png"
        contents["images"].append({
            "size": icon["size"],
            "idiom": icon["idiom"],
            "filename": filename,
            "scale": icon["scale"]
        })
        # Export the PNG
        create_icon(icon["pixels"], f"ios/AppIcon.appiconset/{filename}")

    # Save Contents.json
    with open(os.path.join(ios_path, "Contents.json"), "w") as f:
        json.dump(contents, f, indent=4)


def generate_all_icons():
    print("\n🟦 Generating iOS icons + Contents.json...")
    generate_ios_contents_json()

    print("🟩 Generating Android icons...")
    for size, path in ANDROID_SIZES:
        create_icon(size, path)

    print("🟧 Generating Web + PWA icons...")
    for size, path in WEB_SIZES:
        create_icon(size, path)

    print("🟪 Writing manifest.json...")
    web_dir = os.path.join(OUTPUT_DIR, "web")
    os.makedirs(web_dir, exist_ok=True)
    with open(os.path.join(web_dir, "manifest.json"), "w") as f:
        json.dump(MANIFEST, f, indent=4)

    print("\n✅ All icons generated in:", OUTPUT_DIR)
    print("Copy into your Flutter project as follows:")
    print(" • iOS → ios/Runner/Assets.xcassets/AppIcon.appiconset/")
    print(" • Android → android/app/src/main/res/")
    print(" • Web → web/, web/icons/")


if __name__ == "__main__":
    generate_all_icons()
