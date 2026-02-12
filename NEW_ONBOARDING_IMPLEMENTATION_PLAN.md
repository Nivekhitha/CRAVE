# New Onboarding Screens Implementation Plan

## Overview
Converting 4 React Native onboarding screens to Flutter with animations, progress bars, and CRAVE color scheme.

## Screens to Implement

### 1. Welcome Screen
**Features:**
- Animated chef hat icon with rotation
- Floating decorative icons (utensils, heart) with pulse animation
- Gradient background with decorative circles
- Feature highlights with bullet points
- "Let's get started" button

### 2. Dietary Preferences Screen
**Features:**
- Diet type selection (None, Vegan, Paleo, Keto, etc.)
- Allergy/intolerance chips (Gluten, Dairy, Egg, etc.)
- Progress bar at 33%
- Back, Skip, and Next navigation

### 3. App Purpose Screen
**Features:**
- Four card grid with icons (Discover meals, Eat healthy, Learn to cook, Plan better)
- Multi-select support
- Progress bar at 66%

### 4. Ingredients to Avoid Screen
**Features:**
- Chip selection for common ingredients
- "+ Other" button to add custom items via modal
- Custom ingredients section with remove option
- Progress bar at 100%
- "Get started" button that saves preferences

## Color Scheme
- Cream: #FFF9B4
- Salmon: #D79F90
- Deep Red: #8E1913 (or #C0392B for consistency)
- Dark Brown: #3D351B

## Implementation Steps
1. Create welcome screen with animations
2. Create dietary preferences screen
3. Create purpose screen
4. Create avoid ingredients screen
5. Update navigation flow
6. Test all screens

## Files to Create/Modify
- `lib/screens/onboarding/welcome_screen.dart` (new)
- `lib/screens/onboarding/dietary_preferences_screen.dart` (new)
- `lib/screens/onboarding/purpose_screen.dart` (new)
- `lib/screens/onboarding/avoid_ingredients_screen.dart` (new)
- Update `lib/screens/onboarding/onboarding_screen.dart` or replace it

