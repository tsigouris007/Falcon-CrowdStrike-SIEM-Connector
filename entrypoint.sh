#!/bin/bash

CONFIG="cs.falconhoseclient.cfg"

# Some conditional echoes for sanity
if [ -n "$API_BASE_URL" ]; then 
  echo "[*] Using arguments."
  echo "[+] API Base URL: ${API_BASE_URL}"
else
  echo "[*] Using .env file."
  URL="$(grep API_BASE_URL .env | cut -d'=' -f2)"
  echo "[+] API Base URL: ${URL}"
fi

# Output to the .env file
if [ -n "$CLIENT_ID" ]; then sed -i "s|CLIENT_ID=.*|CLIENT_ID=$CLIENT_ID|" .env; fi
if [ -n "$CLIENT_SECRET" ]; then sed -i "s|CLIENT_SECRET=.*|CLIENT_SECRET=$CLIENT_SECRET|" .env; fi
if [ -n "$API_BASE_URL" ]; then sed -i "s|API_BASE_URL=.*|API_BASE_URL=$API_BASE_URL|" .env; fi

# Substitute things properly
export $(grep -v '^#' .env | xargs) && envsubst < "./${CONFIG}.template" > "./${CONFIG}"

# Copy the final config file to the proper location
mv "./${CONFIG}" /opt/crowdstrike/etc

/opt/crowdstrike/bin/cs.falconhoseclient -nodaemon -config=/opt/crowdstrike/etc/cs.falconhoseclient.cfg 2>&1
