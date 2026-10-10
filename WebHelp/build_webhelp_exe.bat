@echo off
rem Builds build_webhelp.exe from build_webhelp.py and copies it next to CHMer.exe (..\bin and ..\bin64).
rem The exe runs without Python. Building it needs Python 3.8 or later; on the first run PyInstaller is
rem installed into a private virtual environment in %TEMP%, so the system Python stays unchanged.

setlocal
set "SRC=%~dp0"
for %%I in ("%SRC%..") do set "ROOT=%%~fI"
set "WORK=%TEMP%\CHMer_build_webhelp"
set "VPY=%WORK%\venv\Scripts\python.exe"
set "RC=0"

"%VPY%" -c "import PyInstaller" >nul 2>nul && goto :build

rem Each candidate is run: the py launcher can point to a removed Python, and "python" can be the
rem Microsoft Store stub
set "PY="
set "CHECK=import sys, venv; sys.exit(sys.version_info < (3, 8))"
py -3 -c "%CHECK%" >nul 2>nul && set "PY=py -3"
if not defined PY python -c "%CHECK%" >nul 2>nul && set "PY=python"
if not defined PY (
  echo Python 3.8 or later is needed: https://www.python.org/downloads/windows/
  goto :error
)

echo Installing PyInstaller into %WORK%\venv
if exist "%WORK%\venv" rmdir /s /q "%WORK%\venv"
%PY% -m venv "%WORK%\venv" || goto :error
"%VPY%" -m pip install --quiet --disable-pip-version-check pyinstaller || goto :error

:build
echo Building build_webhelp.exe
rem webhelp.js and webhelp.css are packed into the exe, so rebuild it after changing them too
"%VPY%" -m PyInstaller --noconfirm --onefile --noupx --log-level WARN --name build_webhelp ^
  --distpath "%WORK%\dist" --workpath "%WORK%\build" --specpath "%WORK%" ^
  --add-data "%SRC%webhelp.js;." --add-data "%SRC%webhelp.css;." ^
  "%SRC%build_webhelp.py" || goto :error

for %%D in (bin bin64) do (
  if not exist "%ROOT%\%%D" mkdir "%ROOT%\%%D"
  copy /y "%WORK%\dist\build_webhelp.exe" "%ROOT%\%%D\" >nul || goto :error
  echo Copied to %ROOT%\%%D\build_webhelp.exe
)
goto :end

:error
set "RC=1"
echo.
echo Build failed.

:end
rem Keep the window open when started from Explorer
echo %CMDCMDLINE% | findstr /i /c:"%~nx0" >nul && pause
exit /b %RC%
