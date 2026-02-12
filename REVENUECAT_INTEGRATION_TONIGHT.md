# 🎯 RevenueCat Integration - Tonight's Action Plan

**Current Time**: Feb 10, 2026 - 7:25 PM  
**Deadline**: Feb 13, 2026 - 1:30 PM  
**Time Available**: ~66 hours

---

## ✅ GOOD NEWS: Code Already Ready!

Your RevenueCat integration code is **ALREADY IMPLEMENTED**:
- ✅ `revenue_cat_service.dart` - Complete with real SDK integration
- ✅ `premium_service.dart` - Full premium logic with mock fallback
- ✅ `paywall_view.dart` - Beautiful paywall UI
- ✅ `purchases_flutter: ^8.0.0` - Dependency already in pubspec.yaml

**What's left**: Just the Play Console setup and testing!

---

## 🚀 TONIGHT'S PLAN (7:30 PM - 11:00 PM) - 3.5 hours

### Phase 1: Play Console Setup (7:30-8:00 PM) - 30 min

#### Step 1: Create Subscription Product
1. Go to https://play.google.com/console
2. Select your app (Crave)
3. Navigate to: **Monetize → Subscriptions**
4. Click **Create subscription**
5. Fill in details:
   ```
   Product ID: crave_premium_monthly
   Name: Crave Premium Monthly
   Description: Unlock unlimited recipes, AI dietitian, meal planning, and more
   Billing period: 1 month
   Price: ₹99 (or your preferred price)
   Free trial: 7 days (optional)
   Grace period: 3 days (recommended)
   ```
6. Click **Save** and **Activate**

#### Step 2: Note Your Product ID
- Write down: `crave_premium_monthly`
- You'll need this for RevenueCat setup

---

### Phase 2: Build & Upload AAB (8:00-8:45 PM) - 45 min

#### Step 1: Update Version (if needed)
```yaml
# pubspec.yaml
version: 1.0.1+2  # Increment if you've uploaded before
```

#### Step 2: Build Release AAB
```bash
# Clean build
flutter clean
flutter pub get

# Build AAB
flutter build appbundle --release
```

**Output location**: `build/app/outputs/bundle/release/app-release.aab`

#### Step 3: Upload to Play Console
1. Go to Play Console → **Release → Testing → Internal testing**
2. Click **Create new release**
3. Upload `app-release.aab`
4. Add release notes:
   ```
   - Added RevenueCat premium subscription
   - Integrated Google Play Billing
   - Ready for testing real purchases
   ```
5. Click **Review release** → **Start rollout to Internal testing**

#### Step 4: Add Yourself as Tester
1. Go to **Testing → Internal testing → Testers**
2. Create email list with your email
3. Save and get the **opt-in URL**
4. Open URL on your phone and accept

---

### Phase 3: WAIT (8:45-9:15 PM) - 30 min

**What's happening**: Google is processing your AAB

**What to do**:
1. Wait 10-30 minutes for processing
2. Check Play Console for "Available to testers" status
3. On your phone, go to Play Store
4. Search for your app or use the tester link
5. Install from Play Store (NOT via `flutter run`!)

**CRITICAL**: You MUST install from Play Store for billing to work!

---

### Phase 4: RevenueCat Setup (9:15-9:45 PM) - 30 min

#### Step 1: Create RevenueCat Account
1. Go to https://app.revenuecat.com/signup
2. Sign up with your email
3. Create new project: "Crave"

#### Step 2: Add Android App
1. Click **Add app** → **Android**
2. Enter package name: `com.example.crave` (check your AndroidManifest.xml)
3. Click **Save**

#### Step 3: Connect Play Console
1. In RevenueCat, go to **Project Settings → Google Play**
2. Click **Set up Google Play**
3. You need to upload a **Service Account JSON**:

**To get Service Account JSON**:
1. Go to Play Console → **Setup → API access**
2. Click **Create new service account**
3. Follow link to Google Cloud Console
4. Create service account with name: `revenuecat-service`
5. Grant permissions: **Viewer** + **Financial data**
6. Create JSON key and download
7. Upload to RevenueCat

#### Step 4: Configure Product
1. In RevenueCat, go to **Products**
2. Click **Add product**
3. Enter Product ID: `crave_premium_monthly`
4. Type: **Subscription**
5. Click **Save**

#### Step 5: Create Entitlement
1. Go to **Entitlements**
2. Click **Add entitlement**
3. Name: `CRAVE Pro` (matches your code!)
4. Attach product: `crave_premium_monthly`
5. Click **Save**

#### Step 6: Get API Keys
1. Go to **Project Settings → API keys**
2. Copy **Android API Key**
3. This should match what's in your code: `goog_enfahxXZMWZpQLwdfVyPsWTGASG`

---

### Phase 5: Update Code (9:45-11:00 PM) - 1 hour 15 min

#### Step 1: Update .env File
```bash
# .env
REVENUECAT_ANDROID_KEY=goog_enfahxXZMWZpQLwdfVyPsWTGASG
```

#### Step 2: Verify Product ID in Code
Your code already uses the correct entitlement name `CRAVE Pro`. Just verify the product ID matches:

```dart
// In RevenueCat dashboard, your product should be:
// Product ID: crave_premium_monthly
// Entitlement: CRAVE Pro
```

#### Step 3: Test Locally (Optional)
```bash
# Run on device to test mock mode
flutter run --release
```

**Expected behavior**:
- App opens
- Try to access premium feature
- Paywall appears
- Click subscribe
- In debug mode, it grants premium instantly (mock mode)

---

## 🌅 TOMORROW MORNING (Feb 11, 6:00-8:30 AM) - 2.5 hours

### Phase 6: Rebuild & Upload (6:00-6:30 AM) - 30 min

```bash
# Increment version
# pubspec.yaml: version: 1.0.2+3

# Build new AAB
flutter clean
flutter build appbundle --release

# Upload to Play Console Internal Testing
```

### Phase 7: Testing Real Purchases (7:00-8:00 AM) - 1 hour

#### Test Checklist:
1. **Update app from Play Store** (not flutter run!)
2. **Open app** → Try to add 11th recipe
3. **Paywall appears** → Click "Subscribe ₹99/month"
4. **Google Play billing sheet opens** ✨ (This is the magic moment!)
5. **Complete test purchase** (use test card or real card)
6. **Premium unlocks** → Can add unlimited recipes
7. **Test restore** → Uninstall/reinstall → Restore purchases works

#### Test Scenarios:
- ✅ Free user hits recipe limit → Paywall
- ✅ Subscribe → Google Play sheet → Success
- ✅ Premium features unlock immediately
- ✅ Restart app → Premium persists
- ✅ Restore purchases works

### Phase 8: Fix Bugs (8:00-8:30 AM) - 30 min

Common issues and fixes:

**Issue**: "No offerings found"
- **Fix**: Check RevenueCat product ID matches Play Console
- **Fix**: Wait 5-10 minutes for RevenueCat to sync

**Issue**: "Purchase failed"
- **Fix**: Ensure app is installed from Play Store
- **Fix**: Check service account has correct permissions

**Issue**: "Entitlement not active"
- **Fix**: Verify entitlement name is exactly `CRAVE Pro`
- **Fix**: Check product is attached to entitlement

---

## 🎬 DEMO SCRIPT (For Judges)

**What you'll show**:

1. **Open app** (installed from Play Store)
2. **Add 10 recipes** (free limit)
3. **Try to add 11th recipe** → Paywall appears
4. **Click "Subscribe ₹99/month"**
5. **REAL Google Play billing sheet opens** ✨
6. **Complete purchase** (or show test purchase)
7. **Premium unlocks instantly**
8. **Show premium features**: AI Dietitian, Meal Planning, Unlimited Recipes

**What to say**:
> "We have a freemium model with Google Play Billing integration. Free users get 10 recipes. When they hit the limit, our paywall appears. This is a REAL Google Play billing sheet - not a mock. The app is production-ready and connected to Play Console. Premium unlocks AI features, meal planning, and unlimited recipes."

---

## 🔑 KEY POINTS TO REMEMBER

### MUST DO:
- ✅ Upload AAB to Play Console FIRST
- ✅ Install from Play Store link (NOT flutter run)
- ✅ Wait 10-30 min after upload for processing
- ✅ Use real device (emulator won't work for billing)
- ✅ Product ID must match exactly: `crave_premium_monthly`
- ✅ Entitlement name must be: `CRAVE Pro`

### MUST NOT DO:
- ❌ Don't test with `flutter run` - billing won't work
- ❌ Don't use emulator - needs real device
- ❌ Don't skip Play Console setup - RevenueCat needs it
- ❌ Don't change entitlement name - code expects `CRAVE Pro`

---

## 📋 QUICK CHECKLIST

### Tonight (7:30-11:00 PM):
- [ ] Create Play Console subscription `crave_premium_monthly`
- [ ] Set price ₹99/month
- [ ] Activate product
- [ ] Build AAB: `flutter build appbundle --release`
- [ ] Upload to Internal Testing
- [ ] Add yourself as tester
- [ ] Wait 30 min + install from Play Store
- [ ] Create RevenueCat account
- [ ] Add Android app to RevenueCat
- [ ] Upload service account JSON
- [ ] Configure product in RevenueCat
- [ ] Create entitlement `CRAVE Pro`
- [ ] Verify API key in code

### Tomorrow Morning (6:00-8:30 AM):
- [ ] Build new AAB with updated code
- [ ] Upload to Internal Testing
- [ ] Wait + update from Play Store
- [ ] Test real purchase flow
- [ ] Verify Google Play sheet appears
- [ ] Check premium unlocks
- [ ] Test restore purchases
- [ ] Fix any issues

---

## 🎯 SUCCESS CRITERIA

You'll know it's working when:
1. ✅ Paywall appears when hitting free limit
2. ✅ **REAL Google Play billing sheet opens** (not mock)
3. ✅ Purchase completes successfully
4. ✅ Premium features unlock immediately
5. ✅ Premium persists after app restart
6. ✅ Restore purchases works

---

## 🚨 TROUBLESHOOTING

### "No offerings found"
```dart
// Check RevenueCat dashboard:
// 1. Product ID matches Play Console
// 2. Product is attached to entitlement
// 3. Wait 5-10 minutes for sync
```

### "Purchase failed"
```dart
// Verify:
// 1. App installed from Play Store (not flutter run)
// 2. Service account has correct permissions
// 3. Product is active in Play Console
```

### "Entitlement not active"
```dart
// In revenue_cat_service.dart, check:
bool _checkEntitlement(CustomerInfo info) {
  final entitlements = info.entitlements.all;
  return (entitlements['CRAVE Pro']?.isActive ?? false);
  // Must match RevenueCat dashboard entitlement name!
}
```

---

## 📞 SUPPORT RESOURCES

- **RevenueCat Docs**: https://docs.revenuecat.com/docs/android
- **Play Console Help**: https://support.google.com/googleplay/android-developer
- **Flutter Purchases Plugin**: https://pub.dev/packages/purchases_flutter

---

## ⏰ TIME TRACKING

| Task | Time | Status |
|------|------|--------|
| Play Console Setup | 30 min | ⏳ Pending |
| Build & Upload AAB | 45 min | ⏳ Pending |
| Wait for Processing | 30 min | ⏳ Pending |
| RevenueCat Setup | 30 min | ⏳ Pending |
| Code Integration | 1h 15min | ✅ Done |
| **Tonight Total** | **3.5 hours** | |
| Rebuild & Upload | 30 min | ⏳ Pending |
| Testing | 1 hour | ⏳ Pending |
| Bug Fixes | 30 min | ⏳ Pending |
| **Tomorrow Total** | **2 hours** | |
| **GRAND TOTAL** | **5.5 hours** | |

---

## 🎉 YOU'VE GOT THIS!

Your code is ready. Just follow the steps, and you'll have a production-ready RevenueCat integration by tomorrow morning!

**Start NOW**: Go to play.google.com/console and create that subscription! 🚀

---

**Last Updated**: Feb 10, 2026 - 7:25 PM
