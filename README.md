# Demo Argo CD: un cambio en Git actualiza la aplicación

Una página web corre en Kubernetes. Si cambias el mensaje o el color en Git, Argo CD actualiza la página solo. Nadie toca el servidor.

## Qué necesitas

- Docker Desktop, con Kubernetes activado: Settings → Kubernetes → Enable Kubernetes → Apply & restart
- Git
- Una cuenta de GitHub

## Montarlo en tu laptop (unos 10 minutos)

1. Haz **Fork** de este repositorio en GitHub (botón arriba a la derecha).
2. Clona **tu** fork:
   ```
   git clone https://github.com/<tu-usuario>/argocd.git
   cd argocd
   ```
3. Ejecuta el instalador con el URL de **tu** fork.

   Windows (PowerShell):
   ```
   powershell -ExecutionPolicy Bypass -File .\instalar.ps1 -RepoUrl https://github.com/<tu-usuario>/argocd.git
   ```
   Mac / Linux:
   ```
   chmod +x instalar.sh
   ./instalar.sh https://github.com/<tu-usuario>/argocd.git
   ```
4. Al terminar, el instalador muestra la contraseña. Abre:
   - Argo CD: https://localhost:8080 (usuario `admin`; acepta la advertencia del certificado)
   - La app: http://localhost:8081

## La demostración

1. Abre la app en http://localhost:8081: página azul que dice "version 1".
2. Edita `app/deployment.yaml`:
   ```yaml
   - name: MENSAJE
     value: "Hola desde Argo CD - version 2"
   - name: COLOR
     value: "#27AE60"
   ```
3. Sube el cambio:
   ```
   git commit -am "Version 2"
   git push
   ```
4. Espera unos 30 segundos: Argo CD revisa GitHub cada 15 s y aplica el cambio solo, sin presionar nada. (Con **Refresh** en la app `demo-web` es inmediato.)
5. Recarga http://localhost:8081: ahora es verde y dice "version 2".

### Extras

- **Réplicas:** cambia `replicas: 1` a `replicas: 3`, haz push y verás 3 pods en Argo CD.
- **Rollback:** `git revert HEAD` y `git push`, y la página regresa a la versión anterior.
- **Self-heal:** `kubectl scale deploy demo-web --replicas=5` y Argo CD lo regresa a lo que dice Git.

## La idea en una frase

Git dice cómo debe estar la aplicación; Argo CD vigila Git y deja el clúster igual.

## Si algo falla

- **`kubectl` no responde:** revisa que Kubernetes esté en verde en Docker Desktop.
- **La app no abre en el 8081:** ejecuta `kubectl port-forward svc/demo-web 8081:8081` y deja esa ventana abierta.
- **Argo CD no ve el cambio:** confirma que el push llegó a GitHub y presiona Refresh. El repositorio debe ser **público**.
- **Se cerró la ventana del instalador:** vuelve a abrir Argo CD con `kubectl port-forward svc/argocd-server -n argocd 8080:443`.
