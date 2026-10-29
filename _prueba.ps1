Set-Location $PSScriptRoot
function Probar($de, $a, $colDe, $colA, $msg) {
  $f = "app\deployment.yaml"
  (Get-Content $f -Raw).Replace($de, $a).Replace($colDe, $colA) | Set-Content $f -NoNewline
  git commit -q -am $msg 2>$null
  git push -q 2>$null
  $t = [Diagnostics.Stopwatch]::StartNew()
  while ($t.Elapsed.TotalSeconds -lt 120) {
    $s = [int]$t.Elapsed.TotalSeconds
    try { $h = (Invoke-WebRequest -UseBasicParsing "http://127.0.0.1:8081/?t=$s" -DisableKeepAlive -TimeoutSec 3).Content; $v = [regex]::Match($h,'version \d').Value } catch { $v = "ERROR" }
    $ep = kubectl get endpoints demo-web -o jsonpath="{.subsets[*].addresses[*].targetRef.name}" 2>$null
    $pods = (kubectl get pods -l app=demo-web --no-headers 2>$null) -join " | "
    "$msg t=$s pagina=$v endpoints=$ep pods=$pods"
    if ($v -eq $a) { "$msg -> OK en $s s"; return }
    Start-Sleep 3
  }
}
& {
  Probar "version 1" "version 2" "#2E86DE" "#27AE60" "Version 2"
  Probar "version 2" "version 1" "#27AE60" "#2E86DE" "Version 1"
  "=== FIN ==="
} *> _prueba2.log
