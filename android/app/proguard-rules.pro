# Keep PDF library classes
-keep class com.tom_roush.pdfbox.** { *; }
-keep class com.gemalto.jp2.** { *; }
-dontwarn com.gemalto.jp2.**
-dontwarn com.tom_roush.pdfbox.**

# Keep read_pdf_text plugin classes
-keep class io.flutter.plugins.** { *; }

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep Google Generative AI classes
-keep class com.google.ai.** { *; }
-dontwarn com.google.ai.**

# General Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }