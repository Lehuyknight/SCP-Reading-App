# ML Kit khởi tạo các registrar bằng reflection; R8 xóa constructor rỗng sẽ làm plugin không đăng ký được.
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_translate.** { *; }
-keep class com.google.android.gms.internal.mlkit_common.** { *; }
-keep class com.google.firebase.components.** { *; }
-keep class com.google_mlkit_commons.** { *; }
-keep class com.google_mlkit_translation.** { *; }
-dontwarn com.google.mlkit.**
