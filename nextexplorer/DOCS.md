# Next Explorer Ingress

NextExplorer is a modern web-based file manager packaged as a Home Assistant App with native Ingress support.

## Installation

Install the app, start it and open **Web UI**. You can also enable **Show in sidebar** for quick access. No separate web port or reverse proxy is required.

Home Assistant downloads the prebuilt multi-architecture image from GHCR; it does not compile NextExplorer locally.

## Available folders

By default NextExplorer can access:

- **homeassistant_config** — Home Assistant configuration files
- **shared** — Home Assistant share storage
- **media** — Home Assistant media storage
- **backup** — Home Assistant backup storage

These locations are writable. Changes made in NextExplorer affect the real Home Assistant files.

For security, the app no longer exposes `all_addon_configs`, `addons`, or `ssl`. The configuration schema only accepts the four supported root volumes listed above.

## Network storage

For a NAS or other SMB/NFS server, first add the network location to Home Assistant under **Settings → System → Storage → Add network storage**. Choose **Share** or **Media** as appropriate. NextExplorer can then browse the mounted data through its `shared` or `media` volume.

Network shares are intentionally not mounted directly by this app. This keeps network credentials and mount lifecycle in Home Assistant and avoids unnecessary container privileges.

## Authentication

The default authentication mode is `disabled` because Home Assistant Ingress protects access to the app. Keep the app behind Home Assistant Ingress when using this mode.

## Configuration

The Home Assistant UI includes English and Dutch labels and descriptions through `translations/en.yaml` and `translations/nl.yaml`.

### `root_volumes`

Selects which supported Home Assistant storage locations are presented in NextExplorer. Allowed values are `homeassistant_config`, `share`, `media`, and `backup`.

### `auth_mode`

Available values are `disabled`, `local`, `oidc`, and `both`. For normal Home Assistant Ingress use, `disabled` is recommended.

### `log_level`

Available values are `trace`, `debug`, `info`, `warn`, and `error`. Use `info` normally.

### `public_url`

Normally leave this empty for Ingress use. It exists for advanced NextExplorer configurations.

### `env_vars`

Allows advanced NextExplorer environment variables. Values are passed to the application but are deliberately redacted from the startup log.

## Image distribution

The app uses the generic multi-architecture image `ghcr.io/aranaformae/ha-nextexplorer`. GitHub Actions builds native `amd64` and `aarch64` variants, combines them into a multi-arch manifest and signs the published artifacts.

## Security

NextExplorer has read/write access to the folders you enable, so treat the app as an administrator tool.

The app does not require `SYS_ADMIN`, host networking, Docker API access, direct CIFS mounts, autofs or privileged bind mounts. The Home Assistant `map:` configuration uses the current object syntax and requests only the directories actually needed by the app.

A custom `apparmor.txt` profile is included. The Node.js service runs in a restricted child profile with access to the application/runtime paths, cache/temp locations, network traffic required by Ingress and only the Home Assistant directories mapped by `config.yaml`.

Native Node.js addons such as `sqlite3` are shared objects loaded through `dlopen()`. From app version 1.5.2 the AppArmor child profile grants memory-mapping permission to application files. App version 1.5.3 additionally grants explicit read/list access to `/storage/` and the mapped Home Assistant mount roots themselves so root-level volume discovery works without broadening recursive permissions.

CI validates the AppArmor policy with `apparmor_parser`, verifies the native-module and root-directory rules, smoke-tests `sqlite3` against an in-memory database, and lists `/storage` in the built image.

## Troubleshooting

For app version 1.5.3, the startup log should include:

`NEXTEXPLORER HA INGRESS BUILD: 1.5.3`

With the default configuration it should also show `AUTH_MODE: disabled`.

Opening the volume list should show the configured roots without `EACCES: permission denied, scandir '/storage'`.

If the interface opens but a volume is missing, check `root_volumes` and restart the app. If network storage is missing, verify that Home Assistant itself can see the network storage under **Settings → System → Storage**.

If the app fails to start after an AppArmor change, inspect the Home Assistant host audit log for AppArmor `DENIED` entries rather than disabling AppArmor.

## Updates

NextExplorer is pinned to a tested upstream release instead of following `latest`. New app versions are published only after compatibility patches, CI validation and both architecture images have been verified.

See the changelog for detailed release notes and migration information.
