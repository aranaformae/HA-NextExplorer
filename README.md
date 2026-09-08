# HA NextExplorer

Home Assistant App repository for an Ingress-compatible build of [NextExplorer](https://github.com/nxzai/NextExplorer).

The goal of this project is to provide a modern file manager inside Home Assistant without exposing an extra web port or requiring a privileged container.

## Features

- Native Home Assistant Ingress and sidebar support
- Home Assistant authentication as the default authentication boundary
- Access to Home Assistant configuration, share, media and backup folders
- NextExplorer editor, previews, thumbnails and search
- No `SYS_ADMIN` capability
- No direct CIFS/autofs mounts inside the app
- Pinned and tested NextExplorer upstream version
- CI build validation
- Scheduled upstream release monitoring

## Installation

1. Open **Settings → Apps → App Store** in Home Assistant.
2. Open the repository menu and add:

   `https://github.com/aranaformae/HA-NextExplorer`

3. Refresh the App Store.
4. Install **Next Explorer Ingress**.
5. Start the app.
6. Enable **Show in sidebar** if Home Assistant has not already added it.

No host port is exposed. The web interface is served through Home Assistant Ingress.

## Default configuration

By default the following Home Assistant folders are available:

| NextExplorer volume | Home Assistant path | Access |
| --- | --- | --- |
| `homeassistant_config` | `/homeassistant` | Read/write |
| `shared` | `/share` | Read/write |
| `media` | `/media` | Read/write |
| `backup` | `/backup` | Read/write |

The selected `root_volumes` are exposed to NextExplorer through controlled symlinks under its volume root. NextExplorer's volume discovery is patched to recognize these symlinks. This avoids Linux bind mounts and removes the need for `SYS_ADMIN`.

## Network storage

Do not configure SMB/CIFS credentials inside this app.

Mount network storage through Home Assistant OS:

**Settings → System → Storage → Add network storage**

Add the remote storage as a **Share** or **Media** mount. It then becomes accessible to NextExplorer through the corresponding `shared` or `media` volume.

This keeps credentials and mount lifecycle in Home Assistant instead of granting the file-manager container mount privileges.

## Authentication and security

The default `auth_mode` is `disabled`. This is intentional: when NextExplorer is opened through Home Assistant Ingress, Home Assistant already authenticates the user before access to the app is granted.

The app does not expose port 3000 on the Home Assistant host and should normally be used only through Ingress.

Important: the configured volumes are read/write. A Home Assistant administrator using NextExplorer can therefore edit or delete configuration files and backups. Treat the app as an administrative tool.

The current build intentionally avoids:

- `SYS_ADMIN`
- privileged bind mounts
- autofs
- `cifs-utils`
- storage credentials in app options

## Home Assistant Ingress patches

Upstream NextExplorer is designed to run at a normal web root. Home Assistant Ingress serves applications below a dynamic URL prefix, so this repository applies a small compatibility patch during the image build:

- Vite assets use relative paths.
- API requests use a relative base URL.
- Vue Router uses hash history.
- Branding/logo references are made Ingress-safe.
- Volume discovery accepts the controlled symlinks created by the app startup script.

The upstream source itself is not vendored into this repository. A specific release tag is cloned during the build and patched reproducibly.

## Updating

NextExplorer is deliberately pinned to a known upstream release. This prevents an upstream frontend or routing change from silently breaking Home Assistant Ingress.

GitHub Actions performs a build validation for repository changes. A scheduled workflow also checks for newer NextExplorer releases. Upstream releases are reviewed before changing the pin and publishing a new app version.

After an app update, verify that the following volumes open correctly before relying on the new version:

- `homeassistant_config`
- `shared`
- `media`
- `backup`

## Versioning

The Home Assistant App uses its own version number, separate from the bundled NextExplorer version. For example, app `1.4.1` currently packages NextExplorer `v2.2.7` plus the Home Assistant-specific integration patches.

See [CHANGELOG.md](CHANGELOG.md) for user-visible changes.

## Troubleshooting

If the app opens but the interface does not load correctly, first inspect the app log. A current 1.4.1 installation should contain:

`NEXTEXPLORER HA INGRESS BUILD: 1.4.1`

and normally:

`AUTH_MODE: disabled`

If volumes are missing after an update, restart the app once and verify that those volumes are still selected in the app configuration.

## Credits

NextExplorer is developed by the [NextExplorer project](https://github.com/nxzai/NextExplorer). This repository provides the Home Assistant packaging and Ingress compatibility layer.