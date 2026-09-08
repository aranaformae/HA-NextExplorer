# Next Explorer Ingress

NextExplorer is a modern web-based file manager. This Home Assistant App packages it for native Home Assistant Ingress so you can manage files directly from the Home Assistant sidebar.

## Installation

Install the app, start it and open **Web UI**. You can also enable **Show in sidebar** for quick access.

No separate web port or reverse proxy is required.

From version `1.5.0`, Home Assistant downloads a prebuilt multi-architecture image from GHCR instead of compiling NextExplorer locally. This makes installation and updates faster and ensures all users receive the same CI-built image.

## Available folders

By default NextExplorer can access:

- **homeassistant_config** — your Home Assistant configuration files
- **shared** — Home Assistant share storage
- **media** — Home Assistant media storage
- **backup** — Home Assistant backup storage

These locations are writable. Changes made in NextExplorer affect the real Home Assistant files.

## Network storage

For a NAS or other SMB/NFS server, first add the network location to Home Assistant:

**Settings → System → Storage → Add network storage**

Choose **Share** or **Media** as appropriate. NextExplorer can then browse the mounted data through its `shared` or `media` volume.

Network shares are intentionally not mounted directly by this app. This keeps network credentials in Home Assistant and allows the app to run without Linux mount privileges.

## Authentication

The default authentication mode is `disabled` because Home Assistant Ingress protects access to the app.

Keep the app behind Home Assistant Ingress when using this mode. The internal NextExplorer service is not intended to be exposed directly.

## Configuration

### `root_volumes`

Controls which Home Assistant storage locations are presented in NextExplorer.

Default:

```yaml
root_volumes:
  - homeassistant_config
  - share
  - media
  - backup
```

### `auth_mode`

Available values are `disabled`, `local`, `oidc` and `both`.

For normal Home Assistant Ingress use, `disabled` is recommended because Home Assistant already performs authentication.

### `log_level`

Available values: `trace`, `debug`, `info`, `warn`, `error`.

Use `info` normally. Switch temporarily to `debug` when troubleshooting.

### `public_url`

Normally leave this empty for Ingress use. It exists for NextExplorer compatibility and advanced configurations.

### `env_vars`

Allows advanced NextExplorer environment variables to be supplied. Only use this when you understand the corresponding upstream NextExplorer setting.

## Image distribution

The app uses the generic multi-architecture image:

`ghcr.io/aranaformae/ha-nextexplorer`

GitHub Actions builds native `amd64` and `aarch64` variants and combines them into one manifest. The published image is signed during the workflow.

## Security

NextExplorer has read/write access to the folders you enable. In particular, changes to `homeassistant_config` can affect whether Home Assistant starts correctly, and files in `backup` can be deleted. Treat the app as an administrator tool.

The app does not require `SYS_ADMIN`, direct CIFS mounts, autofs, host networking or Docker API access.

A custom `apparmor.txt` profile is included. Startup scripts run in the app profile and the Node.js NextExplorer service transitions into a dedicated restricted child profile. That service profile explicitly allows the app/runtime paths, temporary/cache locations and the Home Assistant directories mapped in `config.yaml`, plus the network access required for Ingress and normal NextExplorer operation.

Home Assistant grants an additional security-rating point to installed apps that provide a custom AppArmor profile.

If NextExplorer stops working after a future feature or upstream update and the logs indicate an AppArmor denial, do not disable AppArmor as a first fix. Inspect the Home Assistant host audit log and add only the specific access that the demonstrated feature requires.

## Troubleshooting

For app version 1.5.0, the startup log should include:

`NEXTEXPLORER HA INGRESS BUILD: 1.5.0`

With the default configuration it should also show:

`AUTH_MODE: disabled`

If the interface opens but a volume is missing, check `root_volumes` in the app configuration and restart the app.

If network storage is missing, first verify that Home Assistant itself can see the network storage under **Settings → System → Storage**.

If the app fails to start after an AppArmor change, inspect the host audit log for AppArmor `DENIED` entries. The repository CI validates the AppArmor policy syntax, but only a running Home Assistant system can exercise every runtime access path.

## Updates

This app pins a tested NextExplorer release instead of automatically following upstream `latest`. This is necessary because Home Assistant Ingress requires a small compatibility patch to NextExplorer's frontend routing and asset handling.

The project automatically checks for newer upstream releases. A new Home Assistant App version is only published after both architecture images and the multi-arch GHCR manifest have built successfully.

See the project changelog for detailed release notes.