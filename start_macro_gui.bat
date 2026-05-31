@echo off
cd /d "%~dp0"
where python >nul 2>nul
if %errorlevel%==0 (
    python vrchat_party_macro_gui.py
) else (
    py -3 vrchat_party_macro_gui.py
)
