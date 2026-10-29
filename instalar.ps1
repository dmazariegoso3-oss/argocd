param(
    [Parameter(Mandatory = $true)]
    [string]$RepoUrl
)

Write-Host "1/4 Instalando Argo CD..." -ForegroundColor Cyan
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

Write-Host "2/4 Esperando a que Argo CD este listo (puede tardar unos minutos)..." -ForegroundColor Cyan
kubectl wait --for=condition=available deployment --all -n argocd --timeout=600s
kubectl rollout status statefulset/argocd-application-controller -n argocd --timeout=600s

Write-Host "3/4 Configurando revision cada 30 segundos y registrando la aplicacion..." -ForegroundColor Cyan
kubectl patch configmap argocd-cm -n argocd --type merge -p '{\"data\":{\"timeout.reconciliation\":\"30s\"}}'
kubectl rollout restart statefulset/argocd-application-controller -n argocd
kubectl rollout status statefulset/argocd-application-controller -n argocd --timeout=600s
(Get-Content "$PSScriptRoot\argocd\application.yaml" -Raw).Replace("REPO_URL", $RepoUrl) | kubectl apply -f -

$b64 = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"
$pass = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b64))

Write-Host ""
Write-Host "4/4 Listo" -ForegroundColor Green
Write-Host "Argo CD:  https://localhost:8080   usuario: admin   contrasena: $pass"
Write-Host "La app:   http://localhost:8081"
Write-Host ""
Write-Host "Deja esta ventana abierta. Ctrl+C para cerrar Argo CD." -ForegroundColor Yellow
kubectl port-forward svc/argocd-server -n argocd 8080:443
