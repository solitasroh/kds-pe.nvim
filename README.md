# KDS PE Plugin for Neovim

Kinetis Design Studio의 Processor Expert 코드 생성과 빌드를 Neovim에서 편리하게 실행할 수 있는 플러그인입니다.

## ✨ 주요 기능

- 🔍 **자동 KDS 프로젝트 감지**: `.project` 파일을 통한 자동 프로젝트 인식
- ⚡ **PE Generate**: Processor Expert 코드 자동 생성
- 🔨 **빌드 지원**: KDS 프로젝트 헤드리스 빌드
- 🖥️ **터미널 통합**: ToggleTerm을 통한 실행 결과 표시
- 📍 **다양한 KDS 버전 지원**: KDS v2, v3 및 사용자 정의 경로

## 📋 요구사항

### 필수 요구사항
- **Neovim** 0.8.0 이상
- **Windows** 환경
- **Kinetis Design Studio** (KDS v2 또는 v3)

### 권장 플러그인
- [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) - 터미널 통합을 위해 필요

## 📦 설치

### lazy.nvim 사용 시
```lua
{
  "your-username/kds-pe.nvim",
  dependencies = {
    "akinsho/toggleterm.nvim"
  },
  ft = { "c", "cpp", "h" }, -- C/C++ 파일에서만 로드
}
```

### Packer 사용 시
```lua
use {
  "your-username/kds-pe.nvim",
  requires = {
    "akinsho/toggleterm.nvim"
  }
}
```

### vim-plug 사용 시
```vim
Plug 'akinsho/toggleterm.nvim'
Plug 'your-username/kds-pe.nvim'
```

## ⚙️ 설정

### 자동 설정
플러그인은 KDS 프로젝트를 자동으로 감지하고 설정됩니다. 별도의 설정이 필요하지 않습니다.

### 수동 설정
```lua
-- KDS 프로젝트가 감지되지 않는 경우 수동으로 활성화
vim.api.nvim_create_user_command("KDSSetup", function()
  require("kds-pe").setup()
end, { desc = "Setup KDS PE plugin manually" })
```

### KDS 설치 경로 설정
KDS가 기본 경로에 설치되지 않은 경우, 환경변수를 설정하세요:
```bash
# PowerShell
$env:KDS_HOME = "C:\\Your\\Custom\\KDS\\Path"

# CMD
set KDS_HOME=C:\Your\Custom\KDS\Path
```

## 🚀 사용법

### 명령어
- `:KDSPEGenerate` - PE 코드 생성
- `:KDSBuild` - 프로젝트 빌드
- `:KDSSetup` - 플러그인 수동 활성화

### 키매핑 (KDS 프로젝트에서만 활성화)
- `<leader>kp` - PE Generate 실행
- `<leader>kb` - Build 실행

### 사용 예시
1. KDS 프로젝트 디렉토리에서 Neovim 실행
2. `<leader>kp` 또는 `:KDSPEGenerate`로 PE 코드 생성
3. `<leader>kb` 또는 `:KDSBuild`로 프로젝트 빌드

## 🔧 KDS 설치 경로 감지

플러그인은 다음 순서로 KDS 설치를 찾습니다:

1. **환경변수 KDS_HOME**
   - `%KDS_HOME%\eclipse\eclipsec.exe`
   - `%KDS_HOME%\eclipse\kinetis-design-studio.exe`
   - `%KDS_HOME%\eclipse\eclipse.exe`

2. **기본 설치 경로**
   - `C:\Freescale\KDS_v3\`
   - `C:\NXP\KDS_v3\`
   - `C:\Program Files\Freescale\KDS_v3\`
   - `C:\Program Files (x86)\Freescale\KDS_v3\`
   - `C:\Freescale\KDS_v2\`
   - `C:\NXP\KDS_v2\`

3. **실행파일 우선순위** (각 경로에서)
   - `eclipsec.exe` (헤드리스 모드, 권장)
   - `kinetis-design-studio.exe` (KDS 전용 실행파일)
   - `eclipse.exe` (일반 Eclipse 실행파일)

## 🏗️ 프로젝트 구조

```
kds-pe.nvim/
├── lua/
│   └── kds-pe/
│       ├── init.lua      # 플러그인 초기화 및 설정
│       ├── commands.lua  # PE Generate 및 Build 명령
│       └── utils.lua     # KDS 프로젝트 감지 및 경로 관리
├── plugin/
│   └── kds-pe.lua       # 플러그인 자동 로더
└── README.md
```

## 🐛 문제 해결

### Java Virtual Machine을 찾을 수 없다는 오류
```
Could not find the Java Virtual Machine
```
**해결방법:**
1. **JRE/JDK 설치**: Java Runtime Environment 8 이상 또는 JDK 8 이상 설치
2. **JAVA_HOME 환경변수 설정**:
   ```bash
   # PowerShell
   $env:JAVA_HOME = "C:\Program Files\Java\jdk-11.0.x"
   
   # CMD  
   set JAVA_HOME=C:\Program Files\Java\jdk-11.0.x
   ```
3. **PATH에 Java bin 디렉토리 추가**:
   ```bash
   # PowerShell
   $env:PATH += ";$env:JAVA_HOME\bin"
   ```
4. **설치 확인**: 터미널에서 `java -version` 실행하여 Java가 정상 작동하는지 확인

### KDS를 찾을 수 없다는 오류
1. KDS가 설치되어 있는지 확인
2. 환경변수 `KDS_HOME` 설정 확인
3. 기본 설치 경로에 KDS가 있는지 확인

### ToggleTerm 관련 오류
```lua
-- lazy.nvim 설정에서 의존성 추가
dependencies = { "akinsho/toggleterm.nvim" }
```

### 프로젝트가 감지되지 않는 경우
- `.project` 파일이 프로젝트 루트에 있는지 확인
- 파일에 KDS 관련 내용이 포함되어 있는지 확인

### 빌드 로그가 터미널에 표시되지 않는 경우
**v1.1 업데이트로 대폭 개선되었습니다!**

**개선사항:**
- `cmd /c` 래퍼로 Windows 환경 최적화
- `2>&1` 리다이렉션으로 stderr도 캡처
- `-consolelog -debug` 옵션으로 상세 로그 출력
- `-vmargs -Declipse.log.level=ALL`로 모든 로그 레벨 표시
- 터미널 크기 20줄로 확대, 스크롤백 50,000줄 지원

**여전히 문제가 있다면:**
1. **터미널 스크롤**: 위로 스크롤하여 출력 내용 확인
2. **워크스페이스 로그**: `.metadata/.log` 파일에서 상세 로그 확인
3. **수동 실행**: `:terminal`로 KDS 명령어 직접 실행

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📜 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다. 자세한 내용은 `LICENSE` 파일을 참조하세요.

## 🙏 감사의 말

- [Kinetis Design Studio](https://www.nxp.com/design/software/development-software/kinetis-design-studio-integrated-development-environment-ide:KDS_IDE) - NXP의 임베디드 개발 환경
- [toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) - 터미널 통합 플러그인