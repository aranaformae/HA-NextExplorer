# HA NextExplorer

Home Assistant App repository for an Ingress-compatible build of [NextExplorer](https://github.com/nxzai/NextExplorer).

The goal is a modern file manager inside Home Assistant without exposing an extra web port or requiring a privileged container.

## Current release

App **1.6.0** packages NextExplorer **v4.0.1** for `amd64` and `aarch64` using the multi-arch image `ghcr.io/aranaformae/ha-nextexplorer`.

## Features

- Native Home Assistant Ingress and sidebar support
- Home Assistant authentication as the default boundary
- Configuration, share, media and backup file access
- NextExplorer editor, previews, thumbnails and search
- Built-in terminal for command-line file management inside the app container
- Custom AppArmor profile
- No `SYS_ADMIN`, host networking, Docker API access, autofs or direct CIFS mounts
- Prebuilt signed multi-arch GHCR images
- English and Dutch Home Assistant configuration translations
- App Store `icon.png`, `logo.png`, `DOCS.md` and `CHANGELOG.md`
- CI AppArmor/build validation, native-module, storage-root and terminal PTY smoke testing

## Installation

Add `https://github.com/aranaformae/HA-NextExplorer` as a Home Assistant App Store repository, install **Next Explorer Ingress**, start it and optionally enable **Show in sidebar**.

No host web port is exposed. Home Assistant downloads the prebuilt image instead of compiling NextExplorer locally.

## Home Assistant storage

The app uses Home Assistant's current object-style `map:` syntax and only requests the mounts it needs: `addon_config`, `homeassistant_config`, `share`, `media`, and `backup`.

Selectable `root_volumes` are restricted to:

| NextExplorer volume | Home Assistant path | Access |
| --- | --- | --- |
| `homeassistant_config` | `/homeassistant` | Read/write |
| `shared` | `/share` | Read/write |
| `media` | `/media` | Read/write |
| `backup` | `/backup` | Read/write |

`all_addon_configs`, `addons`, and `ssl` are intentionally not exposed. Selected root volumes are presented below `/storage` through controlled symlinks. Startup refuses to replace an unexpected real directory at a managed symlink target.

For NAS storage, add SMB/NFS through **Settings → System → Storage → Add network storage** and expose it through Home Assistant Share or Media storage.

## Built-in terminal

From app 1.5.4 the NextExplorer terminal is explicitly supported. It launches Bash through NextExplorer's PTY backend and is useful alongside the graphical file manager for commands such as `ls`, `find`, `grep`, `cp`, `mv` and `mkdir`, including searches and file operations in `/homeassistant`, `/share`, `/media` and `/backup`.

From app **1.5.5**, new terminal sessions default to **`/storage`** instead of the container home directory. This means commands such as `ls` work immediately while `/root` remains inaccessible under AppArmor.

**This is deliberately not a Home Assistant OS or Proxmox host shell.** The terminal runs inside the NextExplorer App container and remains confined by the same AppArmor/container security boundary. It does not provide Docker API access, Supervisor/host administration or unrestricted access to Home Assistant OS. Use Home Assistant's dedicated Terminal & SSH tooling for host-level administration.

The Home Assistant option `terminal_enabled` can disable the terminal backend when it is not needed.

## Authentication and security

`auth_mode: disabled` is the default because Home Assistant Ingress authenticates access before the app is reached. Do not expose the internal NextExplorer service directly in this mode.

A custom `apparmor.txt` profile confines the Node.js service and terminal shells to required application/runtime paths, network traffic and mapped Home Assistant directories. App 1.5.2 added memory-mapping permission for native Node.js addons such as `sqlite3`; app 1.5.3 additionally grants explicit read/list access to the `/storage/` directory and mapped Home Assistant mount roots themselves. App 1.5.4 adds the PTY device permissions required for the built-in terminal without broadening it into a host shell. App 1.5.5 fixes only the terminal's default working directory and does not broaden permissions.

CI validates the AppArmor policy with `apparmor_parser`, checks the required native-module, root-directory and PTY rules, smoke-tests `sqlite3`, lists `/storage`, verifies the terminal working-directory patch and launches Bash through NextExplorer's `node-pty` dependency in the built image.

Advanced `env_vars` values are passed to NextExplorer but are redacted from startup logs.

## Home Assistant conventions

The app folder follows the current Home Assistant layout with `config.yaml`, `Dockerfile`, `apparmor.txt`, `README.md`, `DOCS.md`, `CHANGELOG.md`, `icon.png`, `logo.png`, and `translations/en.yaml` plus `translations/nl.yaml`.

## Ingress compatibility patches

The build patches upstream NextExplorer v4.0.1 so Vite assets and API calls use relative paths, Vue Router uses hash history, branding paths remain Ingress-safe, volume discovery accepts the controlled symlinks created by the app, and terminal sessions default to the app's volume root. Path validation explicitly permits resolved paths only within the four mounted Home Assistant directories (`/homeassistant`, `/share`, `/media`, `/backup`) in addition to `/storage`; other escapes remain blocked.

## Publishing

GitHub Actions builds native `amd64` and `aarch64` images and combines them into the generic multi-arch GHCR manifest. Published images are signed through the Home Assistant builder/Cosign OIDC flow.

The publish workflow runs automatically when `nextexplorer/config.yaml` changes on `main`, and can also be started manually. It builds and publishes both architectures; verify the workflow succeeded before installing. Never reuse a published image tag for changed source.\n\nA daily scheduled upstream check proposes a new stable NextExplorer release in a pull request with an incremented app version. An explicitly dispatched validation run must succeed for the exact candidate commit before automatic merging and publishing. Failed validation leaves the PR open. Preview releases are tracked separately. This is build validation, not a full Home Assistant runtime test; upstream changes may require patch adjustments.

## Verification

For 1.6.0, verify that the startup log contains `NEXTEXPLORER HA INGRESS BUILD: 1.6.0`, that configured volumes open normally, and that a new built-in terminal opens in `/storage` so `pwd` returns `/storage` and `ls` works immediately.

See [CHANGELOG.md](CHANGELOG.md) for release notes.

## Credits

NextExplorer is developed by the [NextExplorer project](https://github.com/nxzai/NextExplorer). This repository provides the Home Assistant packaging and Ingress compatibility layer.
