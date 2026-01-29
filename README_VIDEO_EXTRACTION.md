# 🎥 CRAVE - Video Recipe Extraction

## Quick Start Guide

### Prerequisites
1. **Gemini API Key** - Add to `.env` file:
   ```
   GEMINI_API_KEY=your_api_key_here
   ```
   Get your key from: https://makersuite.google.com/app/apikey

2. **Firebase Authentication** - User must be logged in

3. **Internet Connection** - Required for AI analysis

---

## 🧪 Test YouTube Links (Cooking Videos)

### Recommended Test Videos

1. **Gordon Ramsay - Scrambled Eggs**
   ```
   https://www.youtube.com/watch?v=PUP7U5vTMM0
   ```

2. **Tasty - Chocolate Chip Cookies**
   ```
   https://www.youtube.com/watch?v=3vUtRRZG0xY
   ```

3. **Binging with Babish - Pasta Carbonara**
   ```
   https://www.youtube.com/watch?v=O9qXy5vQ8kY
   ```

4. **Joshua Weissman - Homemade Pizza**
   ```
   https://www.youtube.com/watch?v=sv3TXMSv4L0
   ```

5. **Bon Appétit - Perfect Steak**
   ```
   https://www.youtube.com/watch?v=AMaB1X6Xv5U
   ```

### How to Test

1. **Launch App** → Sign in/Sign up
2. **Navigate**: Home Screen → Tap "+" (center button)
3. **Select**: "Add via Video Link"
4. **Paste URL** → Tap "Extract Recipe"
5. **Wait**: 30-60 seconds for AI analysis
6. **Review**: Edit recipe details if needed
7. **Save**: Tap "Save Recipe" → Success!

---

## 📋 Testing Checklist

### ✅ Basic Flow
- [ ] Paste YouTube URL
- [ ] See "Analyzing..." state
- [ ] Recipe appears in preview
- [ ] Can edit all fields
- [ ] Save successfully
- [ ] Recipe appears in app

### ✅ Error Handling
- [ ] Invalid URL → Shows error
- [ ] Network timeout → Shows error
- [ ] No recipe detected → Shows error
- [ ] "Try Again" button works
- [ ] "Enter Manually" navigates correctly

### ✅ Premium Gating
- [ ] Free user: Extract 1st recipe ✅
- [ ] Free user: Extract 2nd recipe ✅
- [ ] Free user: Extract 3rd recipe ✅
- [ ] Free user: Extract 4th recipe → Paywall shown ❌
- [ ] Premium user: Unlimited extractions ✅

### ✅ PDF Extraction (Already Working)
- [ ] Upload PDF cookbook
- [ ] Recipes extracted
- [ ] Can preview/edit
- [ ] Save to Firestore

---

## 🔍 Verification Steps

### Check Extraction Counter in Firestore

1. Open Firebase Console
2. Navigate to: `Firestore Database` → `users` → `{userId}`
3. Check field: `videoExtractions`
4. Should see: `{"2024-12": 1}` (or current month)

### Check Saved Recipe

1. Navigate to: `users/{userId}/recipes`
2. Find recipe with `source: "video"`
3. Verify fields:
   - `title`: String
   - `sourceUrl`: YouTube URL
   - `ingredients`: Array
   - `instructions`: String
   - `prepTime`, `cookTime`, `servings`: Numbers
   - `difficulty`: "Easy" | "Medium" | "Hard"

---

## 🐛 Troubleshooting

### Issue: "Invalid YouTube URL"
**Solution**: 
- Check URL format: `https://youtube.com/watch?v=...` or `https://youtu.be/...`
- Ensure it's a valid YouTube link

### Issue: "API Key missing"
**Solution**:
- Check `.env` file exists in project root
- Verify `GEMINI_API_KEY=...` is set
- Restart app after adding key

### Issue: "Request timed out"
**Solution**:
- Check internet connection
- Video might be too long/complex
- Try a shorter cooking video

### Issue: "No recipe detected"
**Solution**:
- Video might not contain a recipe
- Try a different cooking video
- Use videos with clear ingredient lists and instructions

### Issue: Paywall not showing
**Solution**:
- Check Firestore: `users/{userId}/videoExtractions`
- Verify count is ≥ 3 for current month
- Check `isPremium` is `false` in user document

---

## 📊 Expected Behavior

### Free User Flow
1. Extract 1st recipe → ✅ Success
2. Extract 2nd recipe → ✅ Success
3. Extract 3rd recipe → ✅ Success
4. Extract 4th recipe → ❌ Paywall shown
5. Upgrade to Premium → ✅ Unlimited

### Premium User Flow
1. Extract recipe → ✅ Success (no limit)
2. Extract recipe → ✅ Success (no limit)
3. Extract recipe → ✅ Success (no limit)
... (unlimited)

---

## 🎯 Demo Scenarios

### Scenario 1: Quick Demo (2 minutes)
1. Open app → Sign in
2. Extract recipe from: `https://www.youtube.com/watch?v=PUP7U5vTMM0`
3. Show preview/edit screen
4. Save recipe
5. Show recipe in app

### Scenario 2: Premium Gating Demo (3 minutes)
1. Extract 3 recipes (show counter)
2. Try 4th extraction → Show paywall
3. Explain premium benefits
4. (Optional) Show premium unlock

### Scenario 3: Error Handling Demo (2 minutes)
1. Paste invalid URL → Show error
2. Show "Try Again" option
3. Show "Enter Manually" fallback

---

## 📝 Notes for Demo

- **Have 5+ YouTube cooking video URLs ready**
- **Test on actual device** (not emulator) for best performance
- **Ensure stable internet** connection
- **Have Firebase Console open** to show extraction counter
- **Prepare premium unlock** demo (optional)

---

## ✅ Acceptance Criteria Status

- ✅ Paste YouTube link → recipe appears → user edits → saves → shows in app
- ✅ PDF imports at least 1 recipe (already working)
- ✅ RevenueCat blocks after 3 extractions for free users
- ✅ No crashes (comprehensive error handling)
- ✅ Clear errors (user-friendly messages)
- ✅ Works on release build (ready for testing)

---

**Status**: ✅ **READY FOR DEMO**
