@echo off
REM SDLPAL Android Build Script for Windows
REM Usage: build-scripts\build-android.bat [debug|release]

setlocal

set SDLPAL_ROOT=%~dp0..
set ANDROID_DIR=%SDLPAL_ROOT%\android

REM --- Environment ---
if not defined JAVA_HOME set JAVA_HOME=D:\dev\AndroidStudio\jbr
if not defined GRADLE_USER_HOME set GRADLE_USER_HOME=D:\dev\gradle-home
if not defined ANDROID_HOME set ANDROID_HOME=D:\dev\android_sdk

REM --- Check junction ---
if not exist "%ANDROID_DIR%\app\src\main\java\org\libsdl\app\SDLActivity.java" (
    echo [SETUP] Creating junction for SDL Java sources...
    if not exist "%ANDROID_DIR%\app\src\main\java\org\libsdl" mkdir "%ANDROID_DIR%\app\src\main\java\org\libsdl"
    mklink /J "%ANDROID_DIR%\app\src\main\java\org\libsdl\app" "%SDLPAL_ROOT%\3rd\SDL\android-project\app\src\main\java\org\libsdl\app"
)

REM --- Build type ---
set BUILD_TYPE=%1
if "%BUILD_TYPE%"=="" set BUILD_TYPE=debug

echo ========================================
echo  SDLPAL Android Build
echo  Type: %BUILD_TYPE%
echo  JAVA_HOME: %JAVA_HOME%
echo  GRADLE_USER_HOME: %GRADLE_USER_HOME%
echo  ANDROID_HOME: %ANDROID_HOME%
echo ========================================

cd /d "%ANDROID_DIR%"
call gradlew assemble%BUILD_TYPE% --no-daemon

if %ERRORLEVEL% neq 0 (
    echo.
    echo [FAILED] Build failed with error %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)

echo.
echo [SUCCESS] Build complete!
echo APK: %ANDROID_DIR%\app\build\outputs\apk\%BUILD_TYPE%\app-%BUILD_TYPE%.apk

endlocal
