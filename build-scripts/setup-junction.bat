@echo off
REM Setup NTFS Junction for SDL Java sources
REM Run this after fresh clone or git clean

setlocal
set SDLPAL_ROOT=%~dp0..
set JUNCTION_PATH=%SDLPAL_ROOT%\android\app\src\main\java\org\libsdl\app
set SDL_JAVA_SRC=%SDLPAL_ROOT%\3rd\SDL\android-project\app\src\main\java\org\libsdl\app

if exist "%JUNCTION_PATH%\SDLActivity.java" (
    echo [OK] Junction already exists.
    exit /b 0
)

if not exist "%SDL_JAVA_SRC%\SDLActivity.java" (
    echo [ERROR] SDL Java sources not found. Did you init submodules?
    echo Run: git config submodule."3rd/SDL".url https://github.com/sdlpal/SDL.git
    echo       git submodule update --init --recursive
    exit /b 1
)

if not exist "%SDLPAL_ROOT%\android\app\src\main\java\org\libsdl" mkdir "%SDLPAL_ROOT%\android\app\src\main\java\org\libsdl"

mklink /J "%JUNCTION_PATH%" "%SDL_JAVA_SRC%"
echo [OK] Junction created: %JUNCTION_PATH% -^> %SDL_JAVA_SRC%
endlocal
