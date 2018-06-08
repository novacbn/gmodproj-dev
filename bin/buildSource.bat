@echo off

:: Configuration for the build
if "%GMODPROJ_BUILD_MODE%"=="" (
    set BUILD_MODE=production
) else (
    set BUILD_MODE=%GMODPROJ_BUILD_MODE%
)

if %BUILD_MODE%==production (
    set BUILD_BINARY=gmodproj.x64.Windows.exe
) else (
    set BUILD_BINARY=gmodproj-dev.x64.Windows.exe
)

:: Dependent versions prerequisites
set LUVI_VERSION="2.7.6"
set LIT_VERSION="3.5.4"
set GMODPROJ_VERSION="0.4.0"

:: Download urls for prerequisites
set LUVI_URL="https://github.com/luvit/luvi/releases/download/v%LUVI_VERSION%/luvi-regular-Windows-amd64.exe"
set LIT_URL="http://lit.luvit.io/packages/luvit/lit/v%LIT_VERSION%.zip"
set GMODPROJ_URL="https://github.com/novacbn/gmodproj/releases/download/%GMODPROJ_VERSION%/gmodproj.x64.Windows.exe"

:: Download prerequisites
echo Downloading prerequisite files...
curl -LfsS -o bin\luvi.exe %LUVI_URL% || goto error
curl -LfsS -o bin\lit.zip %LIT_URL% || goto error
curl -LfsS -o bin\gmodproj.exe %GMODPROJ_URL% || goto error

:: Make luvit.exe
echo. & echo. & echo Making luvit.exe
cd bin
luvi.exe lit.zip -- make lit.zip lit.exe luvi.exe || goto error
lit.exe make lit://luvit/luvit luvit.exe luvi.exe || goto error
cd ..

:: Make gmodproj.exe
echo. & echo. & echo Making gmodproj.exe
bin\gmodproj.exe bin build %BUILD_MODE% || goto error
del bin\gmodproj.exe
move /y "dist\%BUILD_BINARY%" bin > nul
rename "bin\%BUILD_BINARY%" gmodproj.exe

:: Perform cleanup
echo. & echo. & echo Performing cleanup...
del bin\lit.exe
del bin\lit.zip

:: Log completion to user
echo. & echo. & echo Build complete, use 'bin\gmodproj.exe bin build [buildMode]' from now on!

:error
exit /b %errorlevel%