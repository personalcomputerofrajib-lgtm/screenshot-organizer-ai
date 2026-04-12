@echo off
:: ============================================================
::  Screenshot AI — Push to GitHub
::  Run this ONCE after cloning / downloading the source code.
::  Replace the URL below with YOUR repository URL.
:: ============================================================

set REPO_URL=https://github.com/personalcomputerofrajib-lgtm/new.git

echo.
echo [1/4] Initialising git repository...
git init

echo.
echo [2/4] Adding all files...
git add .

echo.
echo [3/4] Creating first commit...
git commit -m "feat: initial Screenshot AI release with full scan, OCR and categories"

echo.
echo [4/4] Pushing to GitHub...
git branch -M main
git remote remove origin 2>nul
git remote add origin %REPO_URL%
git push -u origin main --force

echo.
echo ============================================================
echo  Done! GitHub Actions will now BUILD the APK automatically.
echo  Go to: https://github.com/personalcomputerofrajib-lgtm/new/actions
echo  Wait ~5 minutes, then download the APK from the Releases tab.
echo ============================================================
pause
