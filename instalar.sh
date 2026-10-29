#!/usr/bin/env bash
set -e

if [ -z "$1" ]; then
  echo "Uso: ./instalar.sh https://github.com/<usuario>/argocd.git"
  exit 1
fi

REPO_URL="$1"
DIR="$(cd "$(dirname "$0")" && pwd)"

echo "1/4 Instalando Argo CD..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "2/4 Esperando a que Argo CD este listo (puede tardar unos minutos)..."
kubectl wait --for=condition=available deployment --all -n argocd --timeout=600s
kubectl rollout status statefulset/argocd-application-controller -n argocd --timeout=600s

echo "3/4 Configurando revision cada 30 segundos y registrando la aplicacion..."
kubectl patch configmap argocd-cm -n argocd --type merge -p '{"data":{"timeout.reconciliation":"30s"}}'
kubectl rollout restart statefulset/argocd-application-controller -n argocd
kubectl rollout status statefulset/argocd-application-controller -n argocd --timeout=600s
sed "s|REPO_URL|$REPO_URL|" "$DIR/argocd/application.yaml" | kubectl apply -f -

PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)

echo ""
echo "4/4 Listo"
echo "Argo CD:  https://localhost:8080   usuario: admin   contrasena: $PASS"
echo "La app:   http://localhost:8081"
echo ""
echo "Deja esta terminal abierta. Ctrl+C para cerrar Argo CD."
kubectl port-forward svc/argocd-server -n argocd 8080:443
