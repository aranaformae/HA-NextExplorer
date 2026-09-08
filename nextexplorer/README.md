# Next Explorer Ingress

NextExplorer packaged as a Home Assistant App with native Ingress support.

## Current build

- Home Assistant App: **1.4.1**
- NextExplorer upstream: **v2.2.7**
- Architectures: `amd64`, `aarch64`
- Authentication: Home Assistant Ingress by default
- Host web port: none

## Home Assistant integration

This build adapts NextExplorer for the dynamic URL prefix used by Home Assistant Ingress. During the Docker build it applies compatibility changes for relative frontend assets, relative API calls, hash-based client-side routing and Ingress-safe branding paths.

Home Assistant folders selected in `root_volumes` are exposed below NextExplorer's `/storage` volume root using unprivileged symlinks. Volume discovery is patched to recognize those controlled links.

This means the app no longer needs `SYS_ADMIN`, autofs or its own CIFS client.

## Default volumes

The default configuration exposes:

- `homeassistant_config` — Home Assistant configuration
- `shared` — Home Assistant share storage
- `media` — Home Assistant media storage
- `backup` — Home Assistant backups

All default mappings are read/write.

## Network storage

Configure SMB/NFS storage in Home Assistant under **Settings → System → Storage**. Mount it as Share or Media and access it through NextExplorer's `shared` or `media` volume.

Direct network mounts and credentials are intentionally not supported by this app anymore because they require unnecessary container privileges.

## Authentication

`auth_mode: disabled` is the recommended and default mode when using Home Assistant Ingress. Home Assistant performs authentication before the app can be reached.

Do not expose the internal NextExplorer service directly while authentication is disabled.

## Verifying the installed build

After startup the log should contain:

`NEXTEXPLORER HA INGRESS BUILD: 1.4.1`

and, with the default configuration:

`AUTH_MODE: disabled`

## Updating

Upstream NextExplorer is pinned instead of tracking `latest`. This allows the Ingress patches to be tested against each upstream release before users receive an update.

See the repository `CHANGELOG.md` for release notes and migration information.