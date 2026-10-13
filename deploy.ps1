# 배포 스크립트 (NAS Docker) — 사용: .\deploy.ps1
# 원칙: 배포는 항상 "커밋본"에서. 워킹트리가 더티면 중단.
$ErrorActionPreference = "Stop"

function Invoke-NativeQuiet {
    <#
    .SYNOPSIS
      네이티브 명령(ssh/scp/docker/git 등)을 실행하고 종료코드만 돌려준다.
    .DESCRIPTION
      ⚠ 이걸 안 쓰면 배포가 조용히 깨진다. docker-compose·scp·git 은 **정상 진행 상황도
      stderr 로** 내는데, $ErrorActionPreference='Stop' 아래서는 그 한 줄이
      NativeCommandError 로 올라와 성공하고 있는 명령 도중에 스크립트가 죽는다
      (2026-08-24 qa-app 실측: 빌드는 성공했는데 중단돼 컨테이너는 옛 이미지로 Up =
      배포된 줄 착각). 그래서 이 블록 안에서만 Continue 로 낮추고, 성공 여부는
      $LASTEXITCODE 로만 판정한다.
      Out-Host — 명령 출력을 콘솔로 바로 보내 **함수 반환값에서 뺀다**. 안 그러면
      PowerShell 이 그 출력까지 반환값에 실어 종료코드가 배열이 되고, 성공(0)인데도
      실패로 읽힌다(같은 날 실측).
    .EXAMPLE
      $rc = Invoke-NativeQuiet { scp -O -r src/* "${NAS}:${REMOTE_DIR}/" }
      if ($rc -ne 0) { throw "업로드 실패 (exit $rc)" }
    #>
    param([scriptblock]$Script)
    $prev = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        & $Script | Out-Host
        return $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $prev
    }
}

$dirty = git status --porcelain
if ($dirty) { Write-Error "커밋되지 않은 변경이 있습니다. 먼저 commit 후 배포하세요."; exit 1 }

# ── NAS 정보 (채워서 사용) ──
$NAS        = "admin@192.168.219.2"
$REMOTE_DIR = "/docker/.../app"      # scp 경로는 /volume1 제외 (SFTP chroot)
$CONTAINER  = "<container-name>"

# 예시: 코드 업로드 + 컨테이너 재시작 (종료코드를 반드시 확인할 것)
# $rc = Invoke-NativeQuiet { scp -O -r src/* "${NAS}:${REMOTE_DIR}/" }
# if ($rc -ne 0) { throw "코드 업로드 실패 (exit $rc)" }
# $rc = Invoke-NativeQuiet { ssh $NAS "sudo docker restart $CONTAINER" }
# if ($rc -ne 0) { throw "컨테이너 재시작 실패 (exit $rc)" }

# ── PC 워커를 쓰는 앱이라면: 배포 끝에 워커 코드 사본도 동기화할 것 ──
# deploy 는 NAS 컨테이너만 갱신한다. 무거운 연산을 PC 워커(mlab-worker)로 넘기는
# 앱은 워커가 **워커 PC 의 clone 사본**(C:\mlab-work\code\<앱>)으로 처리하므로,
# 사본을 pull 하지 않으면 그 경로엔 새 코드가 영영 반영되지 않는다
# (2026-08-24 autobook 실측: 21커밋 뒤처진 채 배포된 줄 알았다).
# 구현 예시는 autobook/qa-app/student-report 의 deploy.ps1 마지막 단계 참고.

Write-Host "deploy.ps1 스텁입니다. 위 NAS 정보를 채워 사용하세요."
