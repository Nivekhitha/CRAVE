# 🌞 Crave Light Theme - Visual Guide

## Overview
The light theme uses a **warm, cozy color palette** inspired by natural cooking ingredients and warm kitchen environments. Think cream, terracotta, and warm browns.

---

## 🎨 Color Palette

### Main Background
- **Color**: Warm Cream `#FAF7F2`
- **Where**: Main screen background (entire app background)
- **Feel**: Soft, warm, inviting - like parchment paper or cream

### Cards & Surfaces
- **Color**: Pure White `#FFFFFF`
- **Where**: Recipe cards, action buttons, search bar
- **Feel**: Clean, elevated surfaces on the warm background

### Primary Accent (Buttons & Highlights)
- **Color**: Warm Terracotta `#D4654A`
- **Where**: Primary buttons, active icons, hearts, important actions
- **Feel**: Warm, appetizing - like roasted tomatoes or paprika

### Text Colors
- **Primary Text**: Deep Warm Brown `#2C2417`
  - Main headings, recipe titles, body text
  - Strong contrast on cream background
  
- **Secondary Text**: Muted Brown `#8C8279`
  - Subtitles, descriptions, metadata
  - Softer, less emphasis
  
- **Placeholder Text**: Light Brown `#B5AEA6`
  - Search hints, empty states
  - Very subtle

### Accent Colors
- **Teal** `#5BA5A5` - Hydration tracking, secondary actions
- **Gold** `#D4A857` - Stars, badges, achievements
- **Sage Green** `#7BA47B` - Pantry, ingredients, fresh items

---

## 📱 What You Should See

### Home Screen (Light Mode)
```
┌─────────────────────────────────────┐
│ 🍅 Hello, Chef 👋        ☀️ ❤️ 🚪  │ ← Cream background
│    CRAVE                            │
├─────────────────────────────────────┤
│ 🔍 Search recipes...                │ ← White search bar
├─────────────────────────────────────┤
│ ┌──────┐ ┌──────┐                  │
│ │Pantry│ │Grocery│                 │ ← White cards
│ └──────┘ └──────┘                  │
│ ┌──────┐ ┌──────┐                  │
│ │Planner│ │Journal│                │
│ └──────┘ └──────┘                  │
├─────────────────────────────────────┤
│ 🎭 Mood Cooking Banner              │ ← Terracotta accent
├─────────────────────────────────────┤
│ Today's Picks 🍳                    │ ← Brown text
│ ┌────────┐ ┌────────┐              │
│ │ Recipe │ │ Recipe │              │ ← White cards
│ │  Card  │ │  Card  │              │
│ └────────┘ └────────┘              │
└─────────────────────────────────────┘
```

### Theme Toggle Button
- **In Light Mode**: Shows **SUN icon** ☀️
  - Click it → Switches to Dark Mode (moon appears)
- **Location**: Top right corner of home header
- **Color**: Brown icon on white button background

---

## 🌙 vs ☀️ Quick Comparison

| Element | Light Mode | Dark Mode |
|---------|-----------|-----------|
| Background | Warm Cream `#FAF7F2` | Deep Brown `#1A1612` |
| Cards | White `#FFFFFF` | Dark Brown `#252017` |
| Text | Dark Brown `#2C2417` | Light Cream `#F0EBE3` |
| Accent | Terracotta `#D4654A` | Bright Terracotta `#E07A60` |
| Icon | Sun ☀️ | Moon 🌙 |

---

## ✅ How to Verify Light Theme is Working

1. **Open the app** - Background should be **warm cream**, NOT black
2. **Look at the top right** - Should see a **SUN icon** ☀️
3. **Check cards** - Recipe cards and action buttons should be **white**
4. **Read text** - Text should be **dark brown**, easy to read on cream
5. **Click sun icon** - Should switch to dark mode (background turns dark brown, moon appears)

---

## 🐛 If You Still See Black Background

This means the theme is not being applied correctly. The app might be:
- Still using the old dark theme colors
- Not reading the theme from `ThemeProvider`
- Using static `AppColors` instead of `Theme.of(context)`

**Expected**: Warm cream background with white cards
**Problem**: Black background with dark cards

---

## 🎯 Key Visual Differences

### Light Theme Feel
- **Warm & Inviting**: Like a cozy kitchen with natural light
- **Soft Contrast**: Cream background with white cards
- **Readable**: Dark brown text on light background
- **Appetizing**: Terracotta accents like fresh ingredients

### Dark Theme Feel
- **Sophisticated**: Like a modern restaurant at night
- **Deep & Rich**: Dark brown background with slightly lighter cards
- **Comfortable**: Light cream text on dark background
- **Elegant**: Brighter terracotta accents for contrast

---

## 📸 What to Look For

When you open the app in **light mode**, you should immediately notice:
1. ✅ **Cream/beige background** (NOT black)
2. ✅ **White cards** floating on cream
3. ✅ **Sun icon** in top right
4. ✅ **Dark brown text** (easy to read)
5. ✅ **Terracotta buttons** (warm orange-red)

If you see a **black background**, the theme is NOT working correctly.
