@echo off
cd /d "%~dp0"
(
echo === GIT ===
where git
git --version
echo === DOCKER ===
where docker
docker version
echo === KUBECTL ===
where kubectl
kubectl config current-context
kubectl get nodes
echo === GH ===
where gh
gh auth status
echo === FIN ===
) > verificar.log 2>&1
