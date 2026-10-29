@echo off
cd /d "%~dp0"
(
git init -b main
git config user.name "Darly Mazariegos"
git config user.email "dmazariegoso3-oss@users.noreply.github.com"
git add .
git commit -m "Demo de Argo CD: app web y configuracion GitOps"
git remote remove origin
git remote add origin https://github.com/dmazariegoso3-oss/argocd.git
git push -u origin main
echo === FIN ===
) > publicar.log 2>&1
