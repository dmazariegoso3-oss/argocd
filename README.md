# Demo Argo CD: un cambio en Git actualiza la aplicación

Una página web corre en Kubernetes. Si cambias el mensaje o el color en Git, Argo CD actualiza la página solo. Nadie toca el servidor.

## Qué necesitas

- Docker Desktop con Kubernetes activado: Kubernetes › Create cluster › Kubeadm › Install
- Git y una cuenta de GitHub

## Archivos

| Archivo | Para qué sirve |
| --- | --- |
| `app/deployment.yaml` | La página: mensaje, color y réplicas |
| `app/service.yaml` | Publica la página en el puerto 8081 |
| `argocd/application.yaml` | Le dice a Argo CD qué repositorio y carpeta vigilar |

## Configuración manual

1. Haz **Fork** de este repositorio y clónalo:
   ```
   git clone https://github.com/<tu-usuario>/argocd.git
   cd argocd
   ```
2. En `argocd/application.yaml` cambia `repoURL` por el URL de tu fork.
3. Crea el namespace e instala Argo CD:
   ```
   kubectl create namespace argocd
   kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```
4. Espera a que todos los pods estén en `Running`:
   ```
   kubectl get pods -n argocd
   ```
5. Obtén la contraseña del usuario `admin` (PowerShell):
   ```
   $p = kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"
   [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($p))
   ```
6. Abre el panel de Argo CD (deja esta ventana abierta) y entra a https://localhost:8080:
   ```
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```
7. Registra la aplicación:
   ```
   kubectl apply -f argocd/application.yaml
   ```
8. Abre la app en http://127.0.0.1:8081: página azul que dice "version 1".

### Opcional: que se actualice más rápido

Por defecto Argo CD revisa GitHub cada 3 minutos. Para que revise cada 15 segundos:
```
kubectl patch configmap argocd-cm -n argocd --type merge -p '{\"data\":{\"timeout.reconciliation\":\"15s\",\"timeout.reconciliation.jitter\":\"0s\"}}'
kubectl patch configmap argocd-cmd-params-cm -n argocd --type merge -p '{\"data\":{\"reposerver.revision.cache.expiration\":\"5s\"}}'
kubectl rollout restart deployment/argocd-repo-server -n argocd
kubectl rollout restart statefulset/argocd-application-controller -n argocd
```

## La demostración

1. Edita `app/deployment.yaml`:
   ```yaml
   - name: MENSAJE
     value: "Hola desde Argo CD - version 2"
   - name: COLOR
     value: "#27AE60"
   ```
2. Sube el cambio:
   ```
   git commit -am "Version 2"
   git push
   ```
3. Espera a que Argo CD lo detecte, o presiona **Refresh** en la app `demo-web`.
4. Recarga http://127.0.0.1:8081: ahora es verde y dice "version 2".

**Rollback:** `git revert HEAD` y `git push`, y la página regresa a la versión anterior.

## La idea en una frase

Git dice cómo debe estar la aplicación; Argo CD vigila Git y deja el clúster igual.
