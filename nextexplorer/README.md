# Next Explorer Ingress

Home Assistant App build of NextExplorer with native Ingress support.

This build pins NextExplorer v2.2.3 and applies only the frontend changes required for Home Assistant Ingress:

- relative frontend assets
- relative API calls
- hash-based client-side routing

After starting the app, verify the log contains:

`NEXTEXPLORER HA INGRESS BUILD: 1.3.0-ingress.1`

and:

`AUTH_MODE: disabled`
