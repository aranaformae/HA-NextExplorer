# Next Explorer Ingress

NextExplorer packaged as a Home Assistant App with native Ingress support.

## Current build

- Home Assistant App: **1.5.4**
- NextExplorer upstream: **v2.2.7**
- Architectures: `amd64`, `aarch64`
- Distribution: prebuilt signed multi-arch GHCR image
- Image: `ghcr.io/aranaformae/ha-nextexplorer`
- Authentication: Home Assistant Ingress by default
- Host web port: none
- Security: custom AppArmor profile
- UI translations: English and Dutch

## Home Assistant integration

This build adapts NextExplorer for the dynamic URL prefix used by Home Assistant Ingress. During the Docker build it applies compatibility changes for relative frontend assets, relative API calls, hash-based client-side routing and Ingress-safe branding paths.

Home Assistant folders selected in `root_volumes` are exposed below NextExplorer's `/storage` volume root using controlled unprivileged symlinks. Volume discovery is patched to recognize those links.

The app uses Home Assistant's current object-style `map:` configuration and only requests the mounts it actually needs: `addon_config`, `homeassistant_config`, `share`, `media`, and `backup`.

## Default volumes

The selectable root volumes are:

- `homeassistant_config` — Home Assistant configuration
- `shared` — Home Assistant share storage
- `media` — Home Assistant media storage
- `backup` — Home Assistant backups

All selected mappings are read/write. `all_addon_configs`, `addons`, and `ssl` are intentionally not exposed.

## Built-in terminal

App 1.5.4 explicitly supports NextExplorer's built-in Bash terminal. It is intended for command-line file management alongside the graphical interface, for example with `ls`, `find`, `grep`, `cp`, `mv` and `mkdir` in the mapped `/homeassistant`, `/share`, `/media` and `/backup` directories.

The terminal runs **inside the NextExplorer App container**. It is not a Home Assistant OS host shell or a Proxmox host shell and does not grant Docker API, Supervisor/host administration or unrestricted host access. Terminal child processes remain confined by the app's AppArmor/container security boundary. Use Home Assistant's dedicated Terminal & SSH tooling for host-level administration.

The `terminal_enabled` option enables or disables the terminal backend and defaults to `true`.

## Network storage

Configure SMB/NFS storage in Home Assistant under **Settings → System → Storage**. Mount it as Share or Media and access it through NextExplorer's `shared` or `media` volume.

Direct network mounts and credentials are intentionally not supported by this app because they require unnecessary container privileges.

## Authentication

`auth_mode: disabled` is the recommended and default mode when using Home Assistant Ingress. Home Assistant performs authentication before the app can be reached.

Do not expose the internal NextExplorer service directly while authentication is disabled.

## Security

The app does not use `SYS_ADMIN`, host networking, Docker API access, autofs or direct CIFS mounts. A custom `apparmor.txt` profile confines the Node.js service and terminal shells, and CI validates the profile syntax.

App version 1.5.2 fixed native Node.js addon loading under AppArmor by allowing memory mapping for application files. App version 1.5.3 also allows reading/listing the `/storage/` root and mapped Home Assistant mount roots. App version 1.5.4 adds only the PTY device access required by the built-in terminal.

CI smoke-tests the bundled `sqlite3` native module, listing `/storage`, and a real Bash process launched through NextExplorer's `node-pty` dependency.

Custom `env_vars` values are passed to NextExplorer but redacted from startup logs.

## App Store presentation

The app includes `icon.png`, `logo.png`, `DOCS.md`, `CHANGELOG.md`, and translated configuration metadata in `translations/en.yaml` and `translations/nl.yaml`, following the current Home Assistant App layout.

## Verifying the installed build

After startup the log should contain:

`NEXTEXPLORER HA INGRESS BUILD: 1.5.4`

and, with the default configuration:

`AUTH_MODE: disabled`

`TERMINAL_ENABLED: true`

Opening the volume list should work without `EACCES: permission denied, scandir '/storage'`, and the built-in terminal should present a working prompt and accept commands within the mapped directories.

See `CHANGELOG.md` for release notes and migration information.
