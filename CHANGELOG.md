# Changelog

All notable user-visible changes to the Home Assistant NextExplorer App are documented here.

The Home Assistant App version is independent from the bundled NextExplorer upstream version.

## [1.5.5] - 2026-09-10

### Fixed

- New built-in terminal sessions now start in `/storage`, the NextExplorer volume root, instead of the container home directory (`/root`).
- This prevents the initial `ls: can't open '.': Permission denied` seen when AppArmor correctly blocks `/root`.

### Security

- `/root` remains intentionally inaccessible.
- No AppArmor permissions, Linux capabilities, host access, Docker API access or Supervisor access were added for this fix.

### Validation

- CI now verifies that the Home Assistant build patches NextExplorer's terminal default working directory to prefer `VOLUME_ROOT`.
- Existing AppArmor, `sqlite3`, `/storage` and real `node-pty` Bash smoke tests remain enabled.
- Both `amd64` and `aarch64` images and the multi-architecture `1.5.5` manifest were published successfully before the app version was advanced.

### Compatibility

- Bundled NextExplorer remains `v2.2.7`.
- No configuration migration is required from 1.5.4.

## [1.5.4] - 2026-09-10

### Added

- Added explicit Home Assistant support for NextExplorer's built-in terminal through the `terminal_enabled` option, enabled by default.
- Added English and Dutch configuration descriptions for the terminal option.

### Security

- Added only the PTY device access required by `node-pty` (`/dev/ptmx`, `/dev/pts/**` and `/dev/tty`) to the restricted AppArmor child profile.
- Terminal shells remain inside the same restricted AppArmor/container boundary and do not gain Home Assistant OS, Proxmox, Docker API or Supervisor administration access.

### Validation

- CI now verifies the required PTY AppArmor rules.
- CI now launches a real Bash process through NextExplorer's `node-pty` dependency and verifies terminal output.
- Both `amd64` and `aarch64` images and the signed multi-architecture `1.5.4` manifest were published successfully before the app version was advanced.

### Documentation

- Documented the intended terminal use for command-line file management in mapped Home Assistant directories and clearly distinguished it from a host shell.

### Compatibility

- Bundled NextExplorer remains `v2.2.7`.
- No configuration migration is required from 1.5.3; `terminal_enabled` defaults to `true`.

## [1.5.3] - 2026-09-10

### Fixed

- Fixed `EACCES: permission denied, scandir '/storage'` caused by AppArmor allowing `/storage/**` but not the `/storage/` directory itself.
- Added explicit read/list access to the `/storage/` root and the mapped Home Assistant mount roots (`/homeassistant/`, `/share/`, `/media/`, `/backup/`) while keeping recursive permissions restricted as before.

### Validation

- CI now asserts the required root-directory AppArmor rules.
- CI now smoke-tests listing `/storage` in the built image in addition to the existing native `sqlite3` smoke test.

### Compatibility

- Bundled NextExplorer remains `v2.2.7`.
- No configuration migration is required from 1.5.2.

## [1.5.2] - 2026-09-10

### Fixed

- Fixed an AppArmor regression introduced in 1.5.1 that prevented native Node.js addons such as `sqlite3` from loading with `ERR_DLOPEN_FAILED: Permission denied`.
- The restricted NextExplorer Node.js child profile now grants memory-mapping permission to application files required by native shared objects loaded through `dlopen()`.

### Validation

- CI now explicitly verifies the AppArmor application mapping rule.
- CI smoke-tests the bundled `sqlite3` native module by opening and closing an in-memory database in the built image.
- AppArmor policy syntax continues to be validated with `apparmor_parser`.

### Compatibility

- Bundled NextExplorer remains `v2.2.7`.
- No configuration migration is required from 1.5.1.

## [1.5.1] - 2026-09-08

### Added

- Added a custom Home Assistant `apparmor.txt` profile with a restricted child profile for the NextExplorer Node.js service.
- Added `translations/en.yaml` and `translations/nl.yaml` for configuration labels and descriptions in the Home Assistant UI.
- Added Home Assistant App Store `icon.png` (128x128) and `logo.png` (250x100).

### Changed

- Migrated `map:` entries to Home Assistant's current object syntax using `type` and `read_only`.
- Reduced Home Assistant mounts to the directories actually required by the app: `addon_config`, `homeassistant_config`, `share`, `media`, and `backup`.
- Restricted `root_volumes` validation to `homeassistant_config`, `share`, `media`, and `backup`.
- Updated the runtime build marker to `NEXTEXPLORER HA INGRESS BUILD: 1.5.1`.
- Hardened symlink creation so an unexpected real path under `/storage` is never removed automatically.

### Security

- Removed unused access to `all_addon_configs`, `addons`, and `ssl` from the app configuration and AppArmor service profile.
- Custom environment variable values are no longer written to the startup log; only the variable name and `[set]` are shown.
- AppArmor policy syntax is validated by CI with `apparmor_parser`.
- The app continues to avoid `SYS_ADMIN`, host networking, Docker API access, direct CIFS mounts, and privileged bind mounts.

### Compatibility

- Bundled NextExplorer remains `v2.2.7`.
- Existing default `root_volumes` remain unchanged.
- Configurations that manually selected `all_addon_configs`, `addons`, or `ssl` as a root volume are no longer supported and should use the standard Home Assistant storage locations instead.

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
