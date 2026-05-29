# ============================================================
# DesiFit ProGuard / R8 Rules — Production Release
# ============================================================

# ── CRITICAL: Disable obfuscation ────────────────────────────
# R8 obfuscation renames classes and methods. Flutter plugins
# communicate via platform channels using hardcoded class and
# method names. Obfuscation breaks this, causing instant crashes
# on app launch. Shrinking (dead code removal) stays enabled.
-dontobfuscate

# ── Keep all Flutter engine and plugin registrant classes ─────
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# ── Keep all Google Play Services (Auth, Ads, Base, etc.) ─────
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# ── Keep Firebase SDK ─────────────────────────────────────────
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# ── Keep Google Sign-In ───────────────────────────────────────
-keep class com.google.googlesignin.** { *; }
-dontwarn com.google.googlesignin.**

# ── Keep Google Mobile Ads (AdMob) ────────────────────────────
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# ── Keep Flutter Local Notifications plugin ───────────────────
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# ── Keep Home Widget plugin ───────────────────────────────────
-keep class es.antonborri.home_widget.** { *; }
-dontwarn es.antonborri.home_widget.**

# ── Keep Flutter Timezone plugin ──────────────────────────────
-keep class net.wolverinebeach.flutter_timezone.** { *; }
-dontwarn net.wolverinebeach.flutter_timezone.**

# ── Keep Flutter Secure Storage ───────────────────────────────
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-dontwarn com.it_nomads.fluttersecurestorage.**

# ── Keep URL Launcher ─────────────────────────────────────────
-keep class io.flutter.plugins.urllauncher.** { *; }
-dontwarn io.flutter.plugins.urllauncher.**

# ── Keep WebView Flutter ──────────────────────────────────────
-keep class io.flutter.plugins.webviewflutter.** { *; }
-dontwarn io.flutter.plugins.webviewflutter.**

# ── Keep Hive DB serialization adapters ───────────────────────
-keep class com.hivedb.** { *; }
-keep class ** implements **.TypeAdapter { *; }
-keep class ** extends **.TypeAdapter { *; }

# ── Keep our own app classes ──────────────────────────────────
-keep class com.desifit.app.desifit.** { *; }

# ── Keep Google Play Core (SplitInstall referenced by engine) ─
-dontwarn com.google.android.play.core.**

# ── Keep GSON reflection/serialization ────────────────────────
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# ── Keep Kotlin metadata (needed by some plugins) ────────────
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-dontwarn kotlinx.**

# ── Suppress common harmless warnings ────────────────────────
-dontwarn javax.annotation.**
-dontwarn org.checkerframework.**
-dontwarn com.google.errorprone.annotations.**
-dontwarn org.bouncycastle.**
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.**
