# android/app

## 职责

Android App 模块，包含 Gradle 配置、Manifest、Kotlin 原生入口和 Android 资源。

关键文件：

- `build.gradle.kts`：Android 插件、依赖、SDK 版本配置。
- `src/main/AndroidManifest.xml`：定位、后台定位、前台服务等权限。
- `src/main/kotlin/.../MainActivity.kt`：Flutter Activity 和 Platform Channel。
- `src/main/res/`：启动页、主题、图标资源。

## 构建伪代码

```pseudo
flutter build apk:
  read android/app/build.gradle.kts
  merge AndroidManifest.xml
  compile Kotlin MainActivity
  package Flutter assets and Dart AOT bundle
  output APK/AAB
```

## 注意事项

- 后台定位相关权限必须和 App 内隐私说明、应用商店审核说明一致。
- Android SDK 缺失时本机无法完成 Android build，需要先安装 SDK 并配置 `ANDROID_HOME`。

