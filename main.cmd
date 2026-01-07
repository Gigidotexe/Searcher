@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 
REM mode con: cols=170 lines=30

set FILE=C:\Path\File.txt
set DELIM===BLOCK===
set TOTAL_LINES=30
set EMPTY="" 

if not exist "%FILE%" (
    echo File non trovato!
    pause
    exit /b
)

:INPUT
echo Cerca:
set /p QUERY=

if "!QUERY!"==%EMPTY% goto INPUT
if /I "!QUERY!"=="exit" goto CLEAN_EXIT
cls

set INBLOCK=0
set FOUND=0
set LINE_COUNT=0
set TMP=%CD%\tmp.txt
del "%TMP%" 2>nul

for /f "usebackq delims=" %%A in ("%FILE%") do (
    echo %%A | findstr /C:"%DELIM%" >nul
    if not errorlevel 1 (
        if "!INBLOCK!"=="1" (
            findstr /I /C:"!QUERY!" "%TMP%" >nul
            if not errorlevel 1 (
                echo.
                set /a LINE_COUNT+=1
                for /f "usebackq delims=" %%B in ("%TMP%") do (
                    echo %%B
                    set /a LINE_COUNT+=1
                )
                echo.
                set /a LINE_COUNT+=1
				
                set FOUND=1
            )
        )
        >"%TMP%" echo.
        set INBLOCK=1
    ) else (
        if "!INBLOCK!"=="1" (
            echo %%A>>"%TMP%"
        )
    )
)

if "%FOUND%"=="0" (
    echo Nessuna corrispondenza trovata nel file.
    set /a LINE_COUNT+=1
)

set /a EMPTY_LINES=%TOTAL_LINES% - %LINE_COUNT% - 2
if %EMPTY_LINES% lss 0 set EMPTY_LINES=0
for /L %%i in (1,1,%EMPTY_LINES%) do echo.

goto INPUT

:CLEAN_EXIT
if exist "%TMP%" (
    del "%TMP%"
    echo File temporaneo eliminato: %TMP%
)
echo Uscita dal programma.
exit /b
