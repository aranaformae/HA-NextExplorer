# HA NextExplorer

Home Assistant App repository for an Ingress-compatible build of [NextExplorer](https://github.com/nxzai/NextExplorer).

The goal is a modern file manager inside Home Assistant without exposing an extra web port or requiring a privileged container.

## Current release

App **1.5.2** packages NextExplorer **v2.2.7** for `amd64` and `aarch64` using the signed multi-arch image `ghcr.io/aranaformae/ha-nextexplorer`.

## Features

- Native Home Assistant Ingress and sidebar support
- Home Assistant authentication as the default boundary
- Configuration, share, media and backup file access
- NextExplorer editor, previews, thumbnails and search
- Custom AppArmor profile
- No `SYS_ADMIN`, host networking, Docker API access, autofs or direct CIFS mounts
- Prebuilt signed multi-arch GHCR images
- English and Dutch Home Assistant configuration translations
- App Store `icon.png`, `logo.png`, `DOCS.md` and `CHANGELOG.md`
- CI AppArmor/build validation, native-module smoke testing and upstream release monitoring

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

## Authentication and security

`auth_mode: disabled` is the default because Home Assistant Ingress authenticates access before the app is reached. Do not expose the internal NextExplorer service directly in this mode.

A custom `apparmor.txt` profile confines the Node.js service to required application/runtime paths, network traffic and mapped Home Assistant directories. App 1.5.2 allows memory mapping of application files so native Node.js addons such as `sqlite3` can load correctly without weakening the rest of the child profile.

CI validates the AppArmor policy with `apparmor_parser`, checks the required mapping rule and smoke-tests `sqlite3` in the built image.

Advanced `env_vars` values are passed to NextExplorer but are redacted from startup logs.

## Home Assistant conventions

The app folder follows the current Home Assistant layout with `config.yaml`, `Dockerfile`, `apparmor.txt`, `README.md`, `DOCS.md`, `CHANGELOG.md`, `icon.png`, `logo.png`, and `translations/en.yaml` plus `translations/nl.yaml`.

## Ingress compatibility patches

The build patches upstream NextExplorer so Vite assets and API calls use relative paths, Vue Router uses hash history, branding paths remain Ingress-safe, and volume discovery accepts the controlled symlinks created by the app.

## Publishing

GitHub Actions builds native `amd64` and `aarch64` images and combines them into the generic multi-arch GHCR manifest. Published images are signed through the Home Assistant builder/Cosign OIDC flow.

Never reuse a released image tag for changed source. Build and verify the new image before merging the matching `config.yaml` version into `main`.

## Verification

A 1.5.2 startup should contain:

`NEXTEXPLORER HA INGRESS BUILD: 1.5.2`

and normally `AUTH_MODE: disabled`.

See [CHANGELOG.md](CHANGELOG.md) for release notes.

## Credits

NextExplorer is developed by the [NextExplorer project](https://github.com/nxzai/NextExplorer). This repository provides the Home Assistant packaging and Ingress compatibility layer.
