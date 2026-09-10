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

## Built-in terminal

NextExplorer includes a built-in terminal. In this Home Assistant package the terminal is intended as a companion to the graphical file manager: it gives you a Bash shell **inside the NextExplorer App container** for command-line operations on the files and folders exposed to the app.

Typical uses include:

- listing and navigating the mounted folders with `ls` and `cd`;
- finding files with `find`;
- searching Home Assistant YAML/configuration with `grep`;
- creating directories and copying, moving or renaming files with normal shell tools;
- quickly inspecting files and permissions while working in NextExplorer.

For example:

```bash
find /homeassistant -name "*.yaml"
grep -R "sensor.example" /homeassistant
```

From app **1.5.5**, new terminal sessions start in **`/storage`**, the NextExplorer volume root. This avoids opening in the container home directory (`/root`), which is intentionally inaccessible under AppArmor. As a result, `pwd` should show `/storage` and `ls` should work immediately after opening the terminal.

### Important terminal boundary

The built-in terminal is **not** a Home Assistant OS host shell and is **not** a Proxmox host shell. Commands run inside the NextExplorer App container and remain confined by the app's AppArmor profile and container isolation.

The terminal can work with the Home Assistant directories explicitly mapped into the app, such as `/homeassistant`, `/share`, `/media` and `/backup`, but it does not grant Docker API access, Supervisor/host administration, host networking privileges or unrestricted access to the underlying Home Assistant OS.

Use Home Assistant's dedicated Terminal & SSH tooling when you actually need Home Assistant OS/host administration. The NextExplorer terminal is deliberately scoped to file-management tasks.

The `terminal_enabled` option controls whether NextExplorer's built-in terminal backend is enabled. It is enabled by default. Disabling it removes the PTY functionality when it is not needed.

## Network storage

For a NAS or other SMB/NFS server, first add the network location to Home Assistant under **Settings → System → Storage → Add network storage**. Choose **Share** or **Media** as appropriate. NextExplorer can then browse the mounted data through its `shared` or `media` volume.

Network shares are intentionally not mounted directly by this app. This keeps network credentials and mount lifecycle in Home Assistant and avoids unnecessary container privileges.

## Authentication

The default authentication mode is `disabled` because Home Assistant Ingress protects access to the app. Keep the app behind Home Assistant Ingress when using this mode.

## Configuration

The Home Assistant UI includes English and Dutch labels and descriptions through `translations/en.yaml` and `translations/nl.yaml`.

### `root_volumes`

Selects which supported Home Assistant storage locations are presented in NextExplorer. Allowed values are `homeassistant_config`, `share`, `media`, and `backup`.

### `terminal_enabled`

Enables or disables the built-in NextExplorer terminal. The terminal runs inside the app container and is intended for command-line file management in the directories mapped into NextExplorer; it is not a host shell.

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

A custom `apparmor.txt` profile is included. The Node.js service and the terminal shells it launches run in the restricted child profile with access to the application/runtime paths, cache/temp locations, network traffic required by Ingress and only the Home Assistant directories mapped by `config.yaml`.

Native Node.js addons such as `sqlite3` are shared objects loaded through `dlopen()`. From app version 1.5.2 the AppArmor child profile grants memory-mapping permission to application files. App version 1.5.3 additionally grants explicit read/list access to `/storage/` and the mapped Home Assistant mount roots themselves so root-level volume discovery works without broadening recursive permissions. App version 1.5.4 adds only the PTY device access required by the built-in terminal; it does not turn the terminal into a host shell. App version 1.5.5 changes only the terminal's default working directory to `/storage`; no additional AppArmor permissions are added.

CI validates the AppArmor policy with `apparmor_parser`, verifies the native-module, root-directory and PTY rules, smoke-tests `sqlite3` against an in-memory database, lists `/storage` in the built image, verifies the terminal default-working-directory patch and starts a real Bash process through NextExplorer's `node-pty` dependency.

## Troubleshooting

For app version 1.5.5, the startup log should include:

`NEXTEXPLORER HA INGRESS BUILD: 1.5.5`

With the default configuration it should also show `AUTH_MODE: disabled` and the terminal enabled.

Opening the volume list should show the configured roots without `EACCES: permission denied, scandir '/storage'`.

Opening a new terminal should start at `/storage`. Run `pwd` to confirm and `ls` to list the exposed NextExplorer volumes. If the terminal instead starts elsewhere, make sure 1.5.5 is actually installed and restart the app.

If the terminal UI opens but does not produce a prompt or accept commands, check the app log for AppArmor/PTY errors. Do not disable AppArmor as a workaround.

If the interface opens but a volume is missing, check `root_volumes` and restart the app. If network storage is missing, verify that Home Assistant itself can see the network storage under **Settings → System → Storage**.

If the app fails to start after an AppArmor change, inspect the Home Assistant host audit log for AppArmor `DENIED` entries rather than disabling AppArmor.

## Updates

NextExplorer is pinned to a tested upstream release instead of following `latest`. New app versions are published only after compatibility patches, CI validation and both architecture images have been verified.

See the changelog for detailed release notes and migration information.
