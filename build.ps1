# 실행파일(exe) 빌드 — 결과/중간물을 repo 밖으로 보내 저장소를 깨끗하게 유지(방법 B).
# 사용: .\build.ps1                      # 폴더명으로 exe 생성, .spec 자동 탐색
#       .\build.ps1 -App myapp -Spec app.spec
param(
  [string]$App     = (Split-Path -Leaf (Get-Location)),
  [string]$Spec    = "",
  [string]$Central = "C:\apps"
)
$ErrorActionPreference = "Stop"

if (-not (Get-Command pyinstaller -ErrorAction SilentlyContinue)) {
  Write-Error "pyinstaller가 없습니다. 먼저:  pip install pyinstaller"; exit 1
}

# .spec 자동 탐색
if (-not $Spec) {
  $f = Get-ChildItem -Filter *.spec -File | Select-Object -First 1
  if ($f) { $Spec = $f.Name }
}

$Work = Join-Path $Central "_build\$App"
New-Item -ItemType Directory -Force $Central | Out-Null

if ($Spec) {
  Write-Host "spec로 빌드: $Spec"
  pyinstaller $Spec --noconfirm --distpath $Central --workpath $Work
} else {
  $entry = @("src\main.py","main.py","app.py","src\app.py") | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $entry) { Write-Error ".spec도 진입점(main.py/app.py)도 못 찾음. -Spec 또는 진입점을 지정하세요."; exit 1 }
  Write-Host "onefile 빌드: $entry"
  pyinstaller $entry --onefile --name $App --noconfirm --distpath $Central --workpath $Work
}

Write-Host ""
Write-Host "완료 → $Central\$App (repo 안에는 build/·dist/ 안 생김)"
Write-Host "버전 배포(선택): gh release create vX.Y.Z 로 위 exe 첨부"
