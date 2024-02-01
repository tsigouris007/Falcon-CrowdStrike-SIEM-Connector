# Falcon-CrowdStrike-SIEM-Connector

To use this image properly first create a `.env` file in the root directory of this repository with the following contents:

```
CLIENT_ID=<YOUR_CLIENT_ID>
CLIENT_SECRET=<YOUR_CLIENT_SECRET>
API_BASE_URL=<YOUR_API_URL>
```

The `API_BASE_URL` depends on the region you are:
- US-1: https://api.crowdstrike.com
- US-2: https://api.us-2.crowdstrike.com
- EU-1: https://api.eu-1.crowdstrike.com
- US-GOV-1: https://api.laggar.gcw.crowdstrike.com

Make sure to check out the documentation just in case any of these values changes.

The `CLIENT_ID` and `CLIENT_SECRET` can be produced by visiting `/api-clients-and-keys` UI.
