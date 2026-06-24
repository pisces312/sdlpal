# SDLPAL Android Windows 构建指南

## 环境版本

| 组件 | 版本 |
|------|------|
| Android Gradle Plugin | 9.2.0 |
| Gradle | 9.4.1 |
| NDK | 27.0.12077973 |
| compileSdk | 36 |
| minSdk | 21 |
| targetSdk | 36 |
| ABI | arm64-v8a |
| Java | 17 (Android Studio JBR) |

## 前置条件

1. 已安装 Android Studio（含 JBR）
2. Android SDK + NDK 27.0.12077973
3. Git（已 fork 并 clone sdlpal，submodule 已初始化）

## Submodule 初始化

Fork 后 submodule URL 为相对路径（如 `../SDL.git`），会解析到不存在的 `pisces312/SDL.git`。

需要手动修正为上游 URL：

```powershell
cd D:\3rd-party-projects\sdlpal
git config submodule."3rd/SDL".url https://github.com/sdlpal/SDL.git
git config submodule."3rd/googletest".url https://github.com/sdlpal/googletest.git
git config submodule."3rd/mingw-std-threads".url https://github.com/sdlpal/mingw-std-threads.git
git config submodule."scripts".url https://github.com/sdlpal/scripts.git
git submodule update --init --recursive
```

## SDL Java 源码 Junction

AGP 9 的 sourceSets Groovy DSL 无法正确添加外部 Java 源码目录。
使用 NTFS Junction 将 SDL Java 源码链接到 app 源码树中：

```cmd
mklink /J "android\app\src\main\java\org\libsdl\app" "..\..\..\..\..\3rd\SDL\android-project\app\src\main\java\org\libsdl\app"
```

> 注意：此 Junction 已创建，clone 后需重新创建。参见 `scripts/setup-junction.bat`。

## 构建步骤

```powershell
$env:JAVA_HOME = "D:\dev\AndroidStudio\jbr"
$env:GRADLE_USER_HOME = "D:\dev\gradle-home"
$env:ANDROID_HOME = "D:\dev\android_sdk"

cd D:\3rd-party-projects\sdlpal\android
.\gradlew assembleDebug --no-daemon
```

或直接运行构建脚本：

```cmd
scripts\build-android.bat
```

## 构建产物

- Debug APK: `android\app\build\outputs\apk\debug\app-debug.apk`
- 大小: ~9.35 MB

## 踩坑记录

### 1. Submodule URL 问题
Fork 后 `.gitmodules` 中相对路径 `../SDL.git` 解析到 `pisces312/SDL.git`（不存在）。
**解决**: `git config` 修改各 submodule URL 指向上游 `sdlpal/` 组织。

### 2. AGP 9 找不到 SDL Java 源码
`PalActivity.java` 依赖 `org.libsdl.app.SDLActivity`，源码在 `3rd/SDL/android-project/`。
AGP 9 的 Groovy DSL sourceSets 配置不再生效（`srcDirs +=`、`srcDirs =`、`srcDir()` 均无效）。
**解决**: 用 NTFS Junction 链接目录到 `app/src/main/java/org/libsdl/app/`。

### 3. NDK 链接命令行太长 (Error 87)
Windows 命令行 32767 字符限制，`libmain.so` 链接命令超长（大量 .o 文件路径）。
**解决**: `Application.mk` 添加 `APP_SHORT_COMMANDS := true`，让 ndk-build 使用 response file。

### 4. proguard 配置文件名
`proguard-android.txt` 在 AGP 9 中已废弃，改用 `proguard-android-optimize.txt`。

### 5. multidex 依赖
minSdk >= 21 不需要 multidex，已移除 `androidx.multidex` 依赖。
