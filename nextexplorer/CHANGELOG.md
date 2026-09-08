# Changelog

All notable user-visible changes to the Home Assistant NextExplorer App are documented here.

The Home Assistant App version is independent from the bundled NextExplorer upstream version.

## [1.5.0] - 2026-09-08

### Added

- Added prebuilt GHCR images for `amd64` and `aarch64`.
- Added a signed multi-architecture manifest at `ghcr.io/aranaformae/ha-nextexplorer`.
- Added a dedicated publish workflow using the current Home Assistant builder actions.
- Added Home Assistant App metadata labels to the published images.

### Changed

- Home Assistant now downloads a prebuilt image instead of compiling NextExplorer locally during installation or updates.
- Migrated the Docker build to the current multi-platform `ghcr.io/home-assistant/base` image.
- Removed the legacy `build.yaml` file, following the current Home Assistant App build recommendations.
- App configuration now references the generic multi-arch image name instead of an architecture-specific build path.
- Runtime build marker updated to `NEXTEXPLORER HA INGRESS BUILD: 1.5.0`.

### Benefits

- Faster Home Assistant App installs and updates.
- Reproducible images: all users receive the exact image that passed CI.
- Native `amd64` and `aarch64` builds instead of relying on local Supervisor compilation.
- Published images and the multi-arch manifest are signed by the GitHub Actions workflow using Cosign/OIDC.

### Compatibility

- Bundled NextExplorer remains `v2.2.7`.
- No configuration migration is required when upgrading from `1.4.1`.
- Existing `root_volumes`, authentication settings and environment variables remain unchanged.

## [1.4.1] - 2026-09-08

### Added

- Updated bundled NextExplorer from `v2.2.3` to `v2.2.7`.
- Added CI validation that builds the Home Assistant App on repository changes.
- Added scheduled monitoring for new upstream NextExplorer releases.
- Added explicit support for controlled symlink volumes in NextExplorer's volume discovery.
- Expanded installation, security, network-storage and troubleshooting documentation.

### Changed

- Home Assistant folders are now exposed to NextExplorer using unprivileged symlinks instead of Linux bind mounts.
- Network storage should now be mounted through Home Assistant OS and consumed through the `shared` or `media` volume.
- The app is now designed around Home Assistant Ingress as the authentication boundary and keeps `auth_mode: disabled` as the default.
- Runtime build marker updated to `NEXTEXPLORER HA INGRESS BUILD: 1.4.1`.

### Security

- Removed the `SYS_ADMIN` capability.
- Removed `apparmor: false`, allowing Home Assistant's normal AppArmor handling to apply.
- Removed autofs from the app image and startup services.
- Removed `cifs-utils` and direct CIFS mount handling.
- Removed SMB credentials from app options/schema.
- Eliminated privileged bind mounts for Home Assistant storage.

### Upstream NextExplorer changes included

The move to NextExplorer `v2.2.7` includes upstream improvements such as retry handling for transient network errors, improved handling of large directories and bulk deletes, direct file links for shared files, shared-folder downloads, configurable hidden-file patterns and several UI/build fixes.

### Migration notes

If an older version used the app's `mounts:` option for direct SMB/CIFS mounts, recreate those mounts in Home Assistant under **Settings → System → Storage** before updating. Add them as Share or Media storage so they become available through NextExplorer.

After updating, verify that `homeassistant_config`, `shared`, `media` and `backup` open correctly.

## [1.4.0] - 2026-09-08

### Changed

- Reworked Home Assistant volume exposure to prepare for an unprivileged runtime.
- Replaced bind-mount based volume setup with symlink-based volume setup.

### Security

- Removed the requirement for privileged storage mounting.
- Removed direct network-mount functionality from the app configuration.

### Notes

`1.4.0` was an intermediate refactor immediately superseded by `1.4.1`, which also updates NextExplorer to `v2.2.7` and adds CI/upstream monitoring.

## [1.3.0-ingress.1] - 2026-09-08

### Added

- Initial Home Assistant-specific NextExplorer build.
- Native Home Assistant Ingress support.
- Sidebar integration using `mdi:folder-open` and the title **Bestanden**.
- Home Assistant configuration, share, media and backup volume access.
- Default `auth_mode: disabled` for use behind Home Assistant Ingress.

### Changed from upstream

- Vite frontend assets changed to relative paths for Ingress.
- API base changed from root-relative to relative requests.
- Vue Router changed from web history to hash history to work below Home Assistant's dynamic Ingress prefix.
- Branding/logo references adjusted for Ingress.

### Known limitations

- This first implementation used bind mounts and therefore required `SYS_ADMIN`.
- Direct CIFS mounts were handled inside the container with autofs and `cifs-utils`.

These limitations were removed in the 1.4.x series.
