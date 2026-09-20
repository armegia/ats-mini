# Repository working notes

This file records repository-specific context and operating rules so that future
agents do not need to rediscover the build, hardware, feature provenance, or
private-fork workflow. Read the repository itself as the source of truth.

## Collaboration and ownership

- Communicate with the maintainer in Spanish. Keep source-code comments,
  documentation, changelog entries, and commit messages in English.
- The maintainer's receiver uses ESP32-S3 **OSPI** PSRAM, so OSPI is the
  hardware-tested target.
- Build both the OSPI and QSPI variants. QSPI builds are compile-verified only
  unless someone with QSPI hardware reports a test result; never describe them
  as hardware-tested without that evidence.
- The serial port is intentionally variable. Never hard-code or assume a COM
  port, and do not flash hardware unless the maintainer explicitly requests it.
  The maintainer normally flashes and performs hardware validation.
- Preserve unrelated work in a dirty tree and never stage or revert
  maintainer-owned changes unless explicitly requested.
- Read `CONTRIBUTING.md` and `docs/source/development.md` before making changes,
  follow the surrounding C++ style, and avoid unrelated reformatting.
- Keep board settings in `ats-mini/sketch.yaml` and
  `.github/workflows/build.yml` consistent when changing them.
- For receiver screenshots, follow the repository screenshot skill in
  `.agents/skills/ats-mini-screenshot/SKILL.md`.
- Keep durable project instructions such as this file under version control.
  `.gitignore` should contain generated artifacts, caches, editor leftovers,
  and secrets only; do not use it to hide project documentation or operating
  instructions.
- Preserve the public development attribution for the synchronous-AM fork:
  Antonio (`@armegia`) defined the goal, selected the reference implementation,
  made product and release decisions, reviewed the result, and performed OSPI
  hardware validation. OpenAI Codex performed the repository analysis, feature
  port and integration, build-tooling work, compile validation, upstream merges,
  and documentation/release drafting. Goshante's ATS_EX remains credited as the
  source of the synchronous-AM behavior.

## Build and VS Code workflow

- The Arduino sketch lives in `ats-mini/`; pinned cores, libraries, and board
  profiles are defined in `ats-mini/sketch.yaml`.
- The supported local profiles are `esp32s3-ospi` and `esp32s3-qspi`.
- On Windows, build both variants from the repository root with:

  ```powershell
  .\tools\arduino.ps1 -Action build -Profile esp32s3-ospi
  .\tools\arduino.ps1 -Action build -Profile esp32s3-qspi
  ```

- For a first-time dependency setup, use the VS Code task
  `Arduino: Bootstrap + build (OSPI)` or:

  ```powershell
  .\tools\arduino.ps1 -Action bootstrap -Profile esp32s3-ospi
  ```

- `Ctrl+Shift+B` runs the default VS Code OSPI build task. Use
  `Arduino: Build (QSPI)` for the second variant.
- Successful exported builds are under
  `ats-mini/build/esp32.esp32.esp32s3/`. Both profiles use that same output
  directory, so copy or package one profile's artifacts before compiling the
  other. Important outputs include:
  - `ats-mini.ino.bin`: application firmware only.
  - `ats-mini.ino.bootloader.bin`, `ats-mini.ino.partitions.bin`, and
    `boot_app0.bin`: separate flashing components.
  - `ats-mini.ino.merged.bin`: complete 8 MiB image, flashed by itself at
    address `0x0`.
- A normal validation builds both profiles, checks for zero exit codes, and
  runs `git diff --check`. Existing TFT/core compiler warnings are not
  necessarily regressions, but new warnings in changed code must be
  investigated.
- Release assets should provide clearly named OSPI and QSPI packages. Mark QSPI
  as compile-tested but hardware-untested until a real QSPI receiver validates
  it.
- For every release candidate and published binary, calculate and report both
  SHA-256 and MD5 hashes. SHA-256 is the integrity reference; MD5 is also
  provided because the web flasher displays it for comparison.

## Synchronous AM feature

- The implementation was ported from
  <https://github.com/goshante/ats20_ats_ex> release `v1.18` (reference commit
  `8b9440a`). That project targets different hardware, so use it as behavioral
  and SI4735-register reference only; do not transplant its hardware/UI layer.
- SYNC is an overlay on the existing USB/LSB modes, not a new SI4735 mode. The
  relevant SI4735 patch settings are:
  - synchronous detection: `setSSBDspAfc(0)` and `setSSBAvcDivider(3)`;
  - ordinary SSB: `setSSBDspAfc(1)` and `setSSBAvcDivider(0)`.
- Changing SYNC reloads the SSB patch so the DSP properties take effect. The
  setting is persisted in NVS as `Sync`, is available only in USB/LSB, and is
  shown in the UI as `USB S` or `LSB S`.
- The current development target is based on upstream `2.40` and is displayed
  as `2.40-sync`. Keep fork releases as an upstream version plus a suffix rather
  than pretending to be a new upstream release.
- Current hardware validation used a local AM station at 954 kHz:
  - AM reception worked;
  - ordinary SSB worked and its recovered pitch moved with detuning;
  - SYNC held the recovered pitch stable to approximately 1 kHz of detuning
    (about 953/955 kHz depending on LSB/USB), which is the expected behavior;
  - the OSPI build was flashed and verified successfully after merging the
    Arduino ESP32 core 3.3.11 update;
  - the upstream-2.37 OSPI build was subsequently flashed and verified, so the
    `v2.37-sync` OSPI release is hardware-tested;
  - the exact `v2.38-sync` OSPI release binary was hardware-tested: the
    firmware version, custom splash screen, synchronous AM, manual date/time
    setup from the menu and web page, and WiFi/NTP synchronization worked;
  - the exact `v2.40-sync` OSPI release binary was flashed and hardware-tested:
    synchronous AM continued to work as before, and the automatic GitHub
    update check was refused with the expected message;
  - manual custom-firmware upload through the web interface was not tested for
    the `2.40-sync` candidate;
  - RDS Clock Time synchronization and web authentication were not verified;
  - the QSPI build compiles with core 3.3.11 but remains hardware-untested;
  - a limited indoor test indicated that per-mode squelch responds in AM, but
    it was not tested exhaustively; no useful SSB squelch action was observed,
    as expected from the SI4732 SSB-patch signal-metric limitation;
  - the full set of bandwidth filters has not yet been tested exhaustively.
- User-facing behavior and the validation status belong in
  `docs/source/manual.md`; build instructions belong in
  `docs/source/development.md`; noteworthy changes need a Towncrier fragment in
  `changelog/`. Edit an existing unreleased fragment for the same feature or
  create one if none exists; skip fragments for internal-only changes.

## Git branches and remotes

- `feature/synchronous-am` is the full fork branch, including fork-specific
  tooling and version suffixes.
- `pr/synchronous-am` is a deliberately minimal branch for a possible upstream
  contribution. Do not open a pull request until the maintainer explicitly
  asks; upstream discussion may require GUI changes first.
- `origin` is the private Gitea fork, `github` is the maintainer's public GitHub
  fork, and `upstream` is `https://github.com/esp32-si4732/ats-mini.git`.
- Bring published fork branches up to date with `upstream/main` using a merge
  unless history rewriting is explicitly requested. Rebasing a published
  branch would require a force-push and can disrupt other clones.
- The `v2.35-sync.1` tag is the first experimental synchronous-AM release and
  must remain attached to its original release commit.
- `v2.35-sync.2` is the follow-up release based on Arduino ESP32 core 3.3.11;
  its OSPI build is hardware-tested and its QSPI build is compile-tested only.
- `v2.37-sync` is based on upstream `v2.37`; its OSPI build is hardware-tested
  and its QSPI build is compile-tested only.
- `v2.38-sync` is based on upstream `v2.38`; its exact OSPI release binary is
  hardware-tested and its QSPI build is compile-tested only. RDS Clock Time
  synchronization and web authentication remain unverified.
- `v2.40-sync` is based on upstream `v2.40`; its exact OSPI release binary is
  hardware-tested and its QSPI build is compile-tested only. Its automatic
  GitHub update path refuses official releases while the build has a non-empty
  version suffix and displays the expected message. Manual web upload remains
  available in the code but is not hardware-tested; USB flashing is allowed.

## Private Gitea workflow

- The maintainer's private Gitea is `http://192.168.1.2:3000`, account
  `antonio`. This address is not a credential, but do not publish it in
  user-facing project documentation.
- Repository creation must use `tea` or the Gitea API; SSH can push to an
  existing repository but cannot create one.
- `tea` 0.16.0 is installed through WinGet. The WinGet shim currently fails to
  launch, so invoke the real executable at
  `C:\Users\armeg\AppData\Local\Microsoft\WinGet\Packages\Gitea.tea_Microsoft.Winget.Source_8wekyb3d8bbwe\tea.exe`.
- The default `tea` login is `local-gitea` and targets the private server as
  account `antonio`. Verify it with `tea login status local-gitea` before API
  changes. Do not configure the tea Git credential helper: repository Git
  operations already use SSH, while tea is used only for API operations such
  as repositories and releases.
- For a minimally scoped personal access token that can create the private
  repository via `POST /api/v1/user/repos`, select:
  - access: **all (public, private, and limited)**, not public-only;
  - `repository`: **read and write**;
  - `user`: **read and write**;
  - every other category: **no access**.
- Both write scopes are required by Gitea's nested route middleware: the
  endpoint is in the `/user` group and adds a repository-scope check. A Gitea
  `write` scope also includes read access. The endpoint explicitly rejects a
  public-only token.
- Never place a token in this repository, a remote URL, command history, chat
  output, or Git configuration. `tea` stores its API token in the maintainer's
  per-user configuration; never print or copy that token. For a new login, pass
  it through a temporary `GITEA_SERVER_TOKEN` environment variable populated by
  `Read-Host -MaskInput`, then remove the variable immediately. If the
  maintainer instead supplies a token through a temporary file, read it without
  echoing it, send it only in the Authorization header to this Gitea instance,
  and delete the temporary file after the API operation.
- Create the repository as private and obtain its SSH clone URL from the API
  response rather than constructing it manually.
