# 🎨 Update Crave App Logo Guide

## Your New Logo
- **Design**: Green tomato leaf on orange background
- **Style**: Simple, modern, recognizable
- **Colors**: Orange (#D84315) + Green (#4CAF50)

---

## 📱 Required Icon Sizes

### Android (in `android/app/src/main/res/`)
- `mipmap-mdpi/ic_launcher.png` - 48x48px
- `mipmap-hdpi/ic_launcher.png` - 72x72px
- `mipmap-xhdpi/ic_launcher.png` - 96x96px
- `mipmap-xxhdpi/ic_launcher.png` - 144x144px
- `mipmap-xxxhdpi/ic_launcher.png` - 192x192px

### iOS (in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`)
- `Icon-App-20x20@1x.png` - 20x20px
- `Icon-App-20x20@2x.png` - 40x40px
- `Icon-App-20x20@3x.png` - 60x60px
- `Icon-App-29x29@1x.png` - 29x29px
- `Icon-App-29x29@2x.png` - 58x58px
- `Icon-App-29x29@3x.png` - 87x87px
- `Icon-App-40x40@1x.png` - 40x40px
- `Icon-App-40x40@2x.png` - 80x80px
- `Icon-App-40x40@3x.png` - 120x120px
- `Icon-App-60x60@2x.png` - 120x120px
- `Icon-App-60x60@3x.png` - 180x180px
- `Icon-App-76x76@1x.png` - 76x76px
- `Icon-App-76x76@2x.png` - 152x152px
- `Icon-App-83.5x83.5@2x.png` - 167x167px
- `Icon-App-1024x1024@1x.png` - 1024x1024px

### Web (in `web/icons/`)
- `Icon-192.png` - 192x192px
- `Icon-512.png` - 512x512px
- `Icon-maskable-192.png` - 192x192px
- `Icon-maskable-512.png` - 512x512px

---

## 🛠️ EASY METHOD: Use flutter_launcher_icons Package

### Step 1: Add to pubspec.yaml
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/app_logo.png"
  adaptive_icon_background: "#D84315"  # Orange background
  adaptive_icon_foreground: "assets/app_logo_foreground.png"  # Just the leaf
  web:
    generate: true
    image_path: "assets/app_logo.png"
    background_color: "#D84315"
    theme_color: "#D84315"
```

### Step 2: Save Your Logo
1. Save your logo image as `assets/app_logo.png` (1024x1024px recommended)
2. Create a version with just the leaf (no background) as `assets/app_logo_foreground.png`

### Step 3: Generate Icons
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

This will automatically generate all required icon sizes!

---

## 🎨 MANUAL METHOD: Using Online Tools

### Option 1: AppIcon.co
1. Go to https://appicon.co/
2. Upload your logo (1024x1024px)
3. Download Android, iOS, and Web icon sets
4. Replace files in respective folders

### Option 2: Icon Kitchen
1. Go to https://icon.kitchen/
2. Upload your logo
3. Customize background color (#D84315)
4. Download all platforms
5. Replace files

---

## 📝 QUICK STEPS FOR YOUR LOGO

### 1. Prepare Your Logo File
```bash
# Save your logo as:
assets/app_logo.png (1024x1024px)
```

### 2. Install flutter_launcher_icons
```bash
flutter pub add --dev flutter_launcher_icons
```

### 3. Add Configuration to pubspec.yaml
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/app_logo.png"
  adaptive_icon_background: "#D84315"
  web:
    generate: true
    image_path: "assets/app_logo.png"
```

### 4. Generate Icons
```bash
flutter pub run flutter_launcher_icons
```

### 5. Rebuild App
```bash
flutter clean
flutter pub get
flutter run
```

---

## 🎯 ADAPTIVE ICONS (Android)

For best results on Android, create two versions:

### Background Layer (Square)
- Solid orange color: #D84315
- Size: 1024x1024px
- File: `assets/app_logo_background.png`

### Foreground Layer (Transparent)
- Just the green leaf
- Transparent background
- Size: 1024x1024px
- File: `assets/app_logo_foreground.png`

Then update pubspec.yaml:
```yaml
flutter_launcher_icons:
  android: true
  adaptive_icon_background: "assets/app_logo_background.png"
  adaptive_icon_foreground: "assets/app_logo_foreground.png"
```

---

## 🌐 Web Manifest Update

Update `web/manifest.json`:
```json
{
  "name": "Crave - AI Cooking Assistant",
  "short_name": "Crave",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#D84315",
  "theme_color": "#D84315",
  "description": "Your AI-powered cooking companion",
  "orientation": "portrait-primary",
  "prefer_related_applications": false,
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-maskable-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "maskable"
    },
    {
      "src": "icons/Icon-maskable-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "maskable"
    }
  ]
}
```

---

## ✅ VERIFICATION CHECKLIST

After updating icons:

### Android
- [ ] App icon shows on home screen
- [ ] Icon looks good in app drawer
- [ ] Adaptive icon works (try different launchers)
- [ ] Splash screen shows correctly

### iOS
- [ ] App icon shows on home screen
- [ ] Icon looks good in App Library
- [ ] Icon shows in Settings
- [ ] Spotlight search shows icon

### Web
- [ ] Favicon shows in browser tab
- [ ] PWA icon shows when installed
- [ ] Icon shows in bookmarks

---

## 🎨 DESIGN TIPS

Your logo is great! Here are some tips:

✅ **Good:**
- Simple and recognizable
- Works at small sizes
- Distinct color scheme
- Relevant to cooking

💡 **Suggestions:**
- Ensure leaf is centered
- Add subtle shadow for depth
- Test on light/dark backgrounds
- Consider rounded corners for iOS

---

## 🚀 NEXT STEPS

1. Save your logo as `assets/app_logo.png`
2. Run the flutter_launcher_icons command
3. Test on both Android and iOS
4. Adjust if needed
5. Commit and push to git

---

**Need help?** Let me know and I can:
- Generate the icon files for you
- Create the adaptive icon layers
- Update all configuration files
- Test the icons on device

---

**Last Updated:** February 6, 2026
**Logo:** Green tomato leaf on orange background
**Status:** Ready to implement! 🎨
