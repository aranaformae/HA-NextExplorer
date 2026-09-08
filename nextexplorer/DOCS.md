# Next Explorer Ingress

NextExplorer is a modern web-based file manager. This Home Assistant App packages it for native Home Assistant Ingress so you can manage files directly from the Home Assistant sidebar.

## Installation

Install the app, start it and open **Web UI**. You can also enable **Show in sidebar** for quick access.

No separate web port or reverse proxy is required.

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

## Troubleshooting

For app version 1.4.1, the startup log should include:

`NEXTEXPLORER HA INGRESS BUILD: 1.4.1`

With the default configuration it should also show:

`AUTH_MODE: disabled`

If the interface opens but a volume is missing, check `root_volumes` in the app configuration and restart the app.

If network storage is missing, first verify that Home Assistant itself can see the network storage under **Settings → System → Storage**.

## Security

NextExplorer has read/write access to the folders you enable. In particular, changes to `homeassistant_config` can affect whether Home Assistant starts correctly, and files in `backup` can be deleted.

The app therefore should be treated as an administrator tool. Version 1.4.x no longer requires `SYS_ADMIN`, direct CIFS mounts or autofs.

## Updates

This app pins a tested NextExplorer release instead of automatically following upstream `latest`. This is necessary because Home Assistant Ingress requires a small compatibility patch to NextExplorer's frontend routing and asset handling.

The project automatically checks for newer upstream releases, after which the compatibility changes can be reviewed and tested before an app update is published.

See the project changelog for detailed release notes.