# 🧪 CRAVE - End-to-End Testing Guide

## 📱 **TESTING ON YOUR PHONE RIGHT NOW**

This guide will walk you through testing all major features systematically.

---

## ⏱️ **ESTIMATED TIME: 30-45 minutes**

---

## 🎯 **TEST SEQUENCE**

### **PHASE 1: INITIAL SETUP & AUTHENTICATION** (5 min)

#### **Test 1.1: App Launch**
- [ ] App opens without crashes
- [ ] Splash screen displays correctly
- [ ] No error messages on startup
- [ ] Smooth transition to next screen

**Expected**: Clean app launch with no errors

#### **Test 1.2: Onboarding (if first time)**
- [ ] Onboarding screens display properly
- [ ] Can swipe through 3 screens
- [ ] Images load correctly
- [ ] "Skip" button works
- [ ] "Get Started" button works

**Expected**: Smooth onboarding experience

#### **Test 1.3: Authentication**
- [ ] Login screen appears
- [ ] Can tap "Sign Up" to create account
- [ ] Email/password fields work
- [ ] "Sign Up" button creates account
- [ ] OR "Continue as Guest" works

**Expected**: Successfully logged in or using guest mode

---

### **PHASE 2: HOME & NAVIGATION** (5 min)

#### **Test 2.1: Home Screen**
- [ ] Home screen loads
- [ ] Bottom navigation visible (5 tabs)
- [ ] Hero cards display
- [ ] Quick actions work
- [ ] No loading errors

**Expected**: Clean home screen with all elements

#### **Test 2.2: Bottom Navigation**
- [ ] Tap "Discovery" tab - screen loads
- [ ] Tap "Journal" tab - check if paywall or content shows
- [ ] Tap "Profile" tab - screen loads
- [ ] Tap "Home" tab - returns to home
- [ ] Center FAB (Add Recipe) - opens options

**Expected**: All tabs navigate correctly

---

### **PHASE 3: PREMIUM SYSTEM** (10 min)

#### **Test 3.1: Premium Status Check**
- [ ] Go to Profile tab
- [ ] Check if "Premium" badge shows (should be NO initially)
- [ ] Note your current status

**Expected**: Free user status initially

#### **Test 3.2: Paywall Access**
- [ ] Tap "Journal" tab from bottom nav
- [ ] **CRITICAL**: Paywall should appear
- [ ] Paywall shows "Unlock Your Personal AI Dietitian"
- [ ] Features list displays
- [ ] Pricing options show (Monthly/Yearly)
- [ ] "Continue Free Trial" or "Start Free Trial" button visible

**Expected**: Beautiful paywall screen

#### **Test 3.3: Premium Unlock (CRITICAL TEST)**
- [ ] On paywall, tap "Continue Free Trial" button
- [ ] Wait 1-2 seconds (mock mode delay)
- [ ] **CHECK**: Green success message appears
- [ ] **CHECK**: Screen navigates away (NO BLACK SCREEN)
- [ ] Returns to previous screen OR main screen
- [ ] No crashes or errors

**Expected**: ✅ Smooth navigation, NO black screen

#### **Test 3.4: Verify Premium Access**
- [ ] Go to Profile tab
- [ ] **CHECK**: Premium badge now shows
- [ ] **CHECK**: Stats show "Premium: YES"
- [ ] Go to Journal tab
- [ ] **CHECK**: Journal content loads (no paywall)
- [ ] Go to Nutrition tab
- [ ] **CHECK**: Nutrition dashboard loads (no paywall)

**Expected**: All premium features now accessible

---

### **PHASE 4: RECIPE MANAGEMENT** (10 min)

#### **Test 4.1: Add Recipe (Manual)**
- [ ] Tap center FAB (+ button)
- [ ] Select "Enter Manually"
- [ ] Fill in recipe name: "Test Pasta"
- [ ] Add ingredient: "Pasta, 200g"
- [ ] Add instruction: "Boil water for 10 minutes"
- [ ] Add instruction: "Cook pasta for 5 minutes"
- [ ] Tap "Save"
- [ ] Recipe appears in your collection

**Expected**: Recipe saved successfully

#### **Test 4.2: View Recipe**
- [ ] Find your "Test Pasta" recipe
- [ ] Tap to open
- [ ] Recipe details display
- [ ] Ingredients list shows
- [ ] Instructions show
- [ ] "Start Cooking" button visible

**Expected**: Complete recipe view

#### **Test 4.3: Recipe Extraction (URL)**
- [ ] Tap center FAB (+ button)
- [ ] Select "From URL"
- [ ] Paste a recipe URL (e.g., from AllRecipes.com)
- [ ] Tap "Extract"
- [ ] **CHECK**: Progressive extraction UI shows
- [ ] **CHECK**: "Extracting recipe..." message
- [ ] Wait for completion (may take 10-30 seconds)
- [ ] Recipe data populates
- [ ] Can edit and save

**Expected**: Recipe extracted from URL

---

### **PHASE 5: COOKING MODE** (10 min)

#### **Test 5.1: Start Cooking Session**
- [ ] Open your "Test Pasta" recipe
- [ ] Tap "Start Cooking" button
- [ ] **CHECK**: Fullscreen cooking mode opens
- [ ] **CHECK**: First step displays
- [ ] **CHECK**: Voice reads instruction (if TTS works)
- [ ] **CHECK**: Timer detected for "10 minutes"
- [ ] **CHECK**: Timer countdown starts

**Expected**: Immersive cooking mode active

#### **Test 5.2: Cooking Navigation**
- [ ] Tap screen to advance to next step
- [ ] **CHECK**: Second step shows
- [ ] **CHECK**: Timer for "5 minutes" detected
- [ ] **CHECK**: Progress bar updates
- [ ] Let timer run for a few seconds
- [ ] **CHECK**: Timer counts down

**Expected**: Smooth step progression

#### **Test 5.3: Exit Cooking Mode**
- [ ] Tap back button or exit
- [ ] **CHECK**: Confirmation dialog appears
- [ ] Confirm exit
- [ ] Returns to recipe detail
- [ ] **CHECK**: Cooking stats updated

**Expected**: Clean exit from cooking mode

---

### **PHASE 6: PROFILE & STATISTICS** (5 min)

#### **Test 6.1: Profile Stats**
- [ ] Go to Profile tab
- [ ] **CHECK**: Cooking streak shows
- [ ] **CHECK**: Recipes cooked count increased
- [ ] **CHECK**: Recipes saved count shows
- [ ] **CHECK**: Premium badge visible
- [ ] **CHECK**: Avatar displays

**Expected**: All stats display correctly

#### **Test 6.2: Achievements**
- [ ] Scroll down in profile
- [ ] **CHECK**: Achievement cards show
- [ ] **CHECK**: "First Recipe" achievement unlocked
- [ ] **CHECK**: Progress on other achievements

**Expected**: Achievement system working

---

### **PHASE 7: JOURNAL & NUTRITION** (5 min)

#### **Test 7.1: Food Journal**
- [ ] Tap "Journal" tab
- [ ] **CHECK**: Journal hub loads (no paywall)
- [ ] Tap "Daily Journal"
- [ ] **CHECK**: Can add meal entry
- [ ] Add a test meal
- [ ] **CHECK**: Meal saves

**Expected**: Journal functionality works

#### **Test 7.2: Nutrition Dashboard**
- [ ] Go to main navigation
- [ ] Find Nutrition option
- [ ] **CHECK**: Dashboard loads (no paywall)
- [ ] **CHECK**: Nutrition charts display
- [ ] **CHECK**: Daily/weekly data shows

**Expected**: Nutrition tracking works

---

### **PHASE 8: DISCOVERY & SEARCH** (3 min)

#### **Test 8.1: Discovery**
- [ ] Tap "Discovery" tab
- [ ] **CHECK**: Recipe grid loads
- [ ] **CHECK**: Search bar works
- [ ] **CHECK**: Filter chips work
- [ ] Search for "pasta"
- [ ] **CHECK**: Results filter

**Expected**: Discovery features work

---

### **PHASE 9: OFFLINE MODE** (2 min)

#### **Test 9.1: Offline Functionality**
- [ ] Turn OFF WiFi and mobile data
- [ ] Navigate through app
- [ ] **CHECK**: Previously loaded recipes still accessible
- [ ] **CHECK**: Can view recipe details
- [ ] **CHECK**: Can start cooking mode
- [ ] **CHECK**: App doesn't crash
- [ ] Turn data back ON

**Expected**: App works offline

---

## ✅ **CRITICAL SUCCESS CRITERIA**

### **MUST WORK:**
1. ✅ App launches without crashes
2. ✅ Premium unlock works (NO BLACK SCREEN)
3. ✅ Cooking mode starts and works
4. ✅ Recipe saving works
5. ✅ Navigation between tabs works
6. ✅ Profile stats update
7. ✅ Offline mode works

### **SHOULD WORK:**
- Recipe extraction from URLs
- Voice guidance in cooking mode
- Timers in cooking mode
- Journal entries
- Nutrition tracking
- Search and filters

---

## 🐛 **IF YOU FIND ISSUES**

### **Report Format:**
```
ISSUE: [Brief description]
SCREEN: [Which screen/feature]
STEPS: [How to reproduce]
EXPECTED: [What should happen]
ACTUAL: [What actually happened]
SEVERITY: [Critical/High/Medium/Low]
```

### **Common Issues to Watch For:**
- Black screens after navigation
- App crashes
- Features not loading
- Buttons not responding
- Data not saving
- Premium features still locked after unlock

---

## 📊 **TESTING CHECKLIST SUMMARY**

- [ ] Phase 1: Setup & Auth (5 min)
- [ ] Phase 2: Home & Navigation (5 min)
- [ ] Phase 3: Premium System (10 min) **CRITICAL**
- [ ] Phase 4: Recipe Management (10 min)
- [ ] Phase 5: Cooking Mode (10 min) **CRITICAL**
- [ ] Phase 6: Profile & Stats (5 min)
- [ ] Phase 7: Journal & Nutrition (5 min)
- [ ] Phase 8: Discovery (3 min)
- [ ] Phase 9: Offline Mode (2 min)

**Total Time: ~45 minutes**

---

## 🎯 **PRIORITY TESTS (If Short on Time)**

### **Quick 15-Minute Test:**
1. ✅ Launch app (1 min)
2. ✅ Navigate tabs (2 min)
3. ✅ **Premium unlock test** (3 min) - MOST IMPORTANT
4. ✅ Add manual recipe (3 min)
5. ✅ **Start cooking mode** (3 min) - SECOND MOST IMPORTANT
6. ✅ Check profile stats (2 min)
7. ✅ Test offline (1 min)

---

## 📝 **NOTES**

- Take screenshots of any issues
- Note the exact steps that cause problems
- Check console logs if possible
- Test both with and without internet
- Try different recipes and features
- Pay special attention to premium unlock flow

---

**Good luck with testing! 🚀**

*Focus especially on the premium unlock (no black screen) and cooking mode functionality.*
