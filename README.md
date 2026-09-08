# HA NextExplorer

Home Assistant App repository for an Ingress-compatible build of [NextExplorer](https://github.com/nxzai/NextExplorer).

## Add to Home Assistant

Add this repository to the Home Assistant App Store:

`https://github.com/aranaformae/HA-NextExplorer`

Then install **Next Explorer Ingress**.

## What this build changes

The app currently pins NextExplorer v2.2.7 and patches its frontend for Home Assistant Ingress by using relative assets/API paths, hash-based client-side routing, and Ingress-safe branding assets.

The Home Assistant folders selected in `root_volumes` are exposed inside NextExplorer through unprivileged symlinks. NextExplorer's volume discovery is patched to recognize these controlled symlinks. This avoids bind mounts and removes the need for `SYS_ADMIN`.

## Network storage

Network drives should be mounted by Home Assistant OS via **Settings → System → Storage → Add network storage**. Add the storage as a **Share** or **Media** mount. NextExplorer can then access it through its existing `shared` or `media` volume.

This keeps SMB/NFS credentials and mount lifecycle in Home Assistant instead of inside the NextExplorer container.

## Default volumes

- `homeassistant_config` → Home Assistant configuration
- `shared` → Home Assistant `/share`
- `media` → Home Assistant `/media`
- `backup` → Home Assistant `/backup`

The app runs behind Home Assistant Ingress with NextExplorer authentication disabled by default, so Home Assistant remains the authentication boundary.

## Update strategy

The upstream NextExplorer version is pinned deliberately so an upstream change cannot unexpectedly break the Home Assistant Ingress patches. CI validates the app build and a scheduled check watches for new upstream releases. New versions can then be reviewed and tested before the pin is changed.
