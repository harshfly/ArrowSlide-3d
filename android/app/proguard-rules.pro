# ArrowSlide 3D ProGuard Rules
# Keep Google Mobile Ads SDK
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

# Keep Flutter engine
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep audioplayers native bindings
-keep class xyz.luan.audioplayers.** { *; }

# Keep connectivity_plus
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

# Keep vibration
-keep class com.benjaminabel.vibration.** { *; }

# Prevent stripping of annotations
-keepattributes *Annotation*

# Ignore missing Play Core classes referenced by Flutter engine
-dontwarn com.google.android.play.core.**

# Keep enums used by reflection
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
