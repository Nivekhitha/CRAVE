# Debug Instructions for Paywall Black Screen Issue

## Steps to Debug:

1. **Run the app with logs:**
   ```bash
   flutter run -d "SM A546E" --verbose
   ```

2. **Navigate to the paywall:**
   - Open the app
   - Go to Journal tab
   - Tap "Unlock Your Personal AI Dietitian" button

3. **Click "Continue Free Trial"**

4. **Watch for these debug messages in the terminal:**
   - `🛒 _handlePurchase called` - When you tap the button
   - `🛒 purchasePremium called` - When the purchase method starts
   - `🛡️ Using mock purchase flow` - Confirms it's using demo mode
   - `🛒 Mock purchase: setting premium to true` - When it sets premium status
   - `✅ Premium unlocked via mock flow!` - When it completes
   - `🛒 Purchase result` - The result returned to the UI
   - `🛒 Purchase successful, navigating back` - When it tries to navigate

5. **Look for any error messages:**
   - Lines starting with `❌` indicate errors
   - Lines starting with `⚠️` indicate warnings

## What to Share:

Please copy and paste all the log lines that appear after you click "Continue Free Trial", especially:
- Any lines with 🛒 (shopping cart emoji)
- Any lines with ❌ (error emoji)
- Any lines with ⚠️ (warning emoji)
- Any exception or error stack traces

## Expected Behavior:

After clicking "Continue Free Trial", you should see:
1. A 1-second loading indicator
2. The paywall closes
3. A green snackbar saying "🎉 Premium unlocked (demo mode)!"
4. You should be able to access the AI Dietitian

## If Black Screen Appears:

The black screen means the navigation is failing. The logs will tell us why.
