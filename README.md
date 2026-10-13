# mlabmath-site

> 한 줄 설명 (무엇을 하는 앱/도구인지)

## 구조
- `src/` — 소스 코드 (원본 · 배포·exe 대상)
- `tests/` — 테스트 코드 (소스와 분리 · 배포·exe 빌드에서 제외, git엔 추적)
- `data/` — 데이터 (git 제외, `.gitkeep`만 추적)
- `deploy.ps1` — 배포 스크립트 (해당 시)
- `build.ps1` — 실행파일(exe) 빌드 (결과는 `C:\apps`, repo 밖 출력)
- `CHANGELOG.md` — 변경 이력

## 실행
(작성)

## 배포
배포 대상이면 `deploy.ps1` 사용.

---
### 위생 원칙
- 데이터(.hwpx·.db·이미지·모델)는 **코드 폴더에 두지 않는다** → `data/` 또는 별도 위치/NAS.
- **세션 끝 = commit & push** (원격이 곧 백업).
- 배포는 항상 **커밋본**에서.

