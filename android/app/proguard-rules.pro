# Flutter wrapper and engine.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep annotations used by JSON serialization.
-keepattributes *Annotation*

# Suppress warnings for optional Play Core split-install classes referenced by
# the Flutter embedding (not bundled in a standard build).
-dontwarn com.google.android.play.core.**
