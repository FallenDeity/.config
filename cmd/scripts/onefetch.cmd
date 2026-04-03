where onefetch >nul 2>nul || exit /b 0
git rev-parse --is-inside-work-tree >nul 2>nul || exit /b 0

onefetch