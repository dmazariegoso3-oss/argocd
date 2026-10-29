Set-Location $PSScriptRoot
function Probar($de, $a, $colDe, $colA, $msg) {
  $f = "app\deployment.yaml"
  (Get-Content $f -Raw).Replace($de, $a).Replace($colDe, $colA) | Set-Content $f -NoNewline
  git commit -am $msg | Out-Null
  git push 2>&1 | Out-Null
  $t = [Diagnostics.Stopwatch]::StartNew()
  while ($t.Elapsed.TotalSeconds -lt 150) {
    try { $html = (Invoke-WebRequest -UseBasicParsing http://localhost:8081 -Headers @{"Cache-Control"="no-cache"}).Content } catch { $html = "" }
    if ($html -match [regex]::Escape($a)) { "$msg -> pagina actualizada en $([int]$t.Elapsed.TotalSeconds) s"; return }
    Start-Sleep 2
  }
  "$msg -> NO se actualizo en 150 s"
}
& { 
  Probar "version 1" "version 2" "#2E86DE" "#27AE60" "Version 2"
  Probar "version 2" "version 1" "#27AE60" "#2E86DE" "Version 1"
  "=== FIN ==="
} *> _prueba.log
