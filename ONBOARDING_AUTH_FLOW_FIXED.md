# Onboarding + Auth Flow - FIXED ✅

## Issue
The new onboarding flow was missing login/signup screens. Users went directly from Welcome → Dietary Preferences without authentication.

## Solution
Updated navigation flow to include authentication before onboarding preferences.

---

## ✅ CORRECT FLOW NOW

### For New Users:
```
Splash Screen
    ↓
Welcome Screen ("Let's get started")
    ↓
Login Screen (with "Sign up" link)
    ↓ (if user clicks "Sign up")
Signup Screen
    ↓ (after successful signup)
Dietary Preferences Screen (33% progress)
    ↓
Purpose Screen (66% progress)
    ↓
Avoid Ingredients Screen (100% progress)
    ↓
Main Navigation Screen (Home)
```

### For Returning Users:
```
Splash Screen
    ↓ (checks if user is logged in)
Main Navigation Screen (Home)
```

### If User Logs In (Already Has Account):
```
Login Screen
    ↓ (after successful login)
Main Navigation Screen (Home)
    ↓ (onboarding already completed)
```

---

## Changes Made

### 1. Welcome Screen (`lib/screens/onboarding/welcome_screen.dart`)
**Before**:
```dart
Navigator.pushReplacementNamed(context, '/onboarding/dietary');
```

**After**:
```dart
Navigator.pushReplacementNamed(context, '/login');
```

**Effect**: "Let's get started" button now goes to Login screen

---

### 2. Signup Screen (`lib/screens/auth/signup_screen.dart`)
**Before**:
```dart
Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
```

**After**:
```dart
Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.onboardingDietary, (route) => false);
```

**Effect**: After signup, new users go through onboarding preferences

---

### 3. Login Screen (No Changes Needed)
**Current behavior**: After login → Main Navigation Screen

**Why**: Existing users have already completed onboarding, so they go directly to the app.

---

## User Experience

### New User Journey:
1. **Opens app** → Sees splash screen with logo animation
2. **Welcome screen** → Sees "CRAVE" branding, features, "Let's get started" button
3. **Login screen** → Can login or click "Don't have an account? Sign up"
4. **Signup screen** → Creates account with email, password, username, country
5. **Dietary preferences** → Selects diet type and allergies (33% progress)
6. **Purpose selection** → Chooses why they're using the app (66% progress)
7. **Avoid ingredients** → Adds ingredients to avoid (100% progress)
8. **Main app** → Full access to all features

### Returning User Journey:
1. **Opens app** → Sees splash screen
2. **Automatically logged in** → Goes directly to Main Navigation
3. **No onboarding** → Already completed

---

## Data Flow

### Signup → Onboarding → Main:
```dart
// 1. Signup creates user in Firebase Auth
AuthService.signUpWithEmailAndPassword(email, password)

// 2. Creates user profile in Firestore
FirestoreService.createUserProfile(uid, username, country, email)

// 3. Navigates to dietary preferences
Navigator.pushNamedAndRemoveUntil('/onboarding/dietary')

// 4. User completes onboarding (dietary → purpose → avoid)
// Each screen passes data via arguments

// 5. Avoid ingredients screen saves all data
FirestoreService.updateUserProfile({
  'dietaryPreference': diet,
  'allergies': allergies,
  'appPurposes': purposes,
  'ingredientsToAvoid': ingredientsToAvoid,
  'onboardingCompleted': true,
})

// 6. Navigates to main app
Navigator.pushNamedAndRemoveUntil('/main')
```

---

## Testing Checklist

- [x] Welcome screen → Login screen ✅
- [x] Login screen has "Sign up" link ✅
- [x] Signup → Dietary preferences ✅
- [x] Dietary → Purpose → Avoid → Main ✅
- [x] Login (existing user) → Main directly ✅
- [x] Splash checks auth state correctly ✅
- [x] No diagnostic errors ✅

---

## Files Modified

1. `lib/screens/onboarding/welcome_screen.dart`
   - Changed button navigation from `/onboarding/dietary` to `/login`

2. `lib/screens/auth/signup_screen.dart`
   - Changed post-signup navigation from `/main` to `/onboarding/dietary`

---

## Complete Navigation Map

```
/                           → SplashScreen
  ├─ (not logged in)       → /onboarding/welcome
  └─ (logged in)           → /main

/onboarding/welcome         → WelcomeScreen
  └─ "Let's get started"   → /login

/login                      → LoginScreen
  ├─ "Sign up"             → /signup
  └─ (success)             → /main

/signup                     → SignupScreen
  └─ (success)             → /onboarding/dietary

/onboarding/dietary         → DietaryPreferencesScreen
  ├─ "Back"                → /login
  ├─ "Skip"                → /onboarding/purpose
  └─ "Next"                → /onboarding/purpose

/onboarding/purpose         → PurposeScreen
  ├─ "Back"                → /onboarding/dietary
  ├─ "Skip"                → /onboarding/avoid
  └─ "Next"                → /onboarding/avoid

/onboarding/avoid           → AvoidIngredientsScreen
  ├─ "Back"                → /onboarding/purpose
  ├─ "Skip"                → /main
  └─ "Get started"         → /main

/main                       → MainNavigationScreen
  └─ (bottom nav)          → Home, Discovery, Add Recipe, Journal, Profile
```

---

## Status
✅ **Complete and tested**  
✅ **No diagnostic errors**  
✅ **Proper authentication flow**  
✅ **Onboarding only for new users**

---

**Date**: Feb 10, 2026  
**Issue**: Missing login/signup in onboarding flow  
**Resolution**: Added authentication before onboarding preferences
