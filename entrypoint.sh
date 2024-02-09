#!/bin/bash

WORKDIR="/home/user"
CONFIGDIR="/opt/crowdstrike/etc"
CONFIG="cs.falconhoseclient.cfg"

# Read the .env file properties
F_CLIENT_ID="$(grep CLIENT_ID .env | awk -F'=' '{print $2}')"
F_CLIENT_SECRET="$(grep CLIENT_SECRET .env | awk -F'=' '{print $2}')"
F_API_BASE_URL="$(grep API_BASE_URL .env | awk -F'=' '{print $2}')"

# Set the necessary variables
if [ -n "$F_CLIENT_ID" ] && [ -z "$CLIENT_ID" ]; then
  CLIENT_ID="$(echo $F_CLIENT_ID)"
fi

if [ -n "$F_CLIENT_SECRET" ] && [ -z "$CLIENT_SECRET" ]; then
  CLIENT_SECRET="$(echo $F_CLIENT_SECRET)"
fi

if [ -n "$F_API_BASE_URL" ] && [ -z "$API_BASE_URL" ]; then
  API_BASE_URL="$(echo $F_API_BASE_URL)"
fi

if [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ] || [ -z "$API_BASE_URL" ]; then
  echo "[-] Please define CLIENT_ID, CLIENT_SECRET, API_BASE_URL."
  exit 1
fi

# Sanity echo
echo "API Base URL: $API_BASE_URL"

# Substitute things properly
export $(echo "CLIENT_ID=$CLIENT_ID CLIENT_SECRET=$CLIENT_SECRET API_BASE_URL=$API_BASE_URL") && envsubst < "${WORKDIR}/${CONFIG}.template" > "${CONFIGDIR}/${CONFIG}"

cs.falconhoseclient -nodaemon -config="${CONFIGDIR}/${CONFIG}" 2>&1
