#!/usr/bin/env bash
#
# REQUIREMENTS:
# 1. Install jq: `sudo apt install jq` (Debian/Ubuntu) or `brew install jq` (Mac)
# 2. Set these environment variables:
#    - DROPBOX_CLIENT_ID: Your Dropbox app's client ID
#    - DROPBOX_CLIENT_SECRET: Your Dropbox app's client secret
#    - DROPBOX_REFRESH_TOKEN: Your long-lived refresh token (from initial auth)
# 3. Do NOT set DROPBOX_API_ACCESS_TOKEN (the script manages it)

URL="https://content.dropboxapi.com/2/files/download"
APRIP_ARGS="Dropbox-API-Arg: {\"path\":\"/Open Commentary Update Files/GN_A Pausanias reader in progress, restarted 2020.05.01(1)-Gipson-6-18-2022(1).docx\"}"
APRIP_DESTINATION="static/editions/aprip.docx"
APCIP_ARGS="Dropbox-API-Arg: {\"path\":\"/Open Commentary Update Files/GN_Ongoing comments on APRIP(1)(1)_with-images.docx\"}"
APCIP_DESTINATION="static/commentaries/apcip.docx"

# Check for required tools
if ! command -v jq &> /dev/null; then
  echo "Error: 'jq' is required. Install it with 'sudo apt install jq' or 'brew install jq'." >&2
  exit 1
fi

# Check for required env vars
for var in DROPBOX_CLIENT_ID DROPBOX_CLIENT_SECRET DROPBOX_REFRESH_TOKEN; do
  if [ -z "${!var}" ]; then
    echo "Error: $var is not set." >&2
    exit 1
  fi
done

# Function to refresh access token; prints token to stdout, errors to stderr
refresh_token() {
  local response
  response=$(curl -s -X POST "https://api.dropboxapi.com/oauth2/token" \
    -d "grant_type=refresh_token" \
    -d "refresh_token=$DROPBOX_REFRESH_TOKEN" \
    -d "client_id=$DROPBOX_CLIENT_ID" \
    -d "client_secret=$DROPBOX_CLIENT_SECRET")

  if echo "$response" | grep -q "error"; then
    echo "Error refreshing token: $(echo "$response" | jq -r '.error_description')" >&2
    exit 1
  fi
  echo "$response" | jq -r '.access_token'
}

# Validate that a file is a ZIP/DOCX by checking its magic bytes
assert_docx() {
  local file="$1"
  local label="$2"
  if ! xxd -l 4 "$file" 2>/dev/null | grep -q "504b 0304"; then
    echo "Error: $label does not appear to be a valid DOCX file. Response body:"
    cat "$file"
    exit 1
  fi
}

# Download a file, refreshing the token on 401, and validate the result
download_file() {
  local api_arg="$1"
  local destination="$2"
  local label="$3"

  local temp_file
  temp_file=$(mktemp)

  local http_code
  http_code=$(curl -X POST "$URL" \
    --header "$AUTH_HEADER" \
    --header "$api_arg" \
    -o "$temp_file" \
    -w "%{http_code}" -s)

  if [ "$http_code" != "200" ]; then
    echo "Error downloading $label (HTTP $http_code):"
    cat "$temp_file"
    rm -f "$temp_file"
    exit 1
  fi

  assert_docx "$temp_file" "$label"
  mv "$temp_file" "$destination"
  echo "Downloaded $label successfully."
}

echo "Fetching Dropbox access token..."
TOKEN=$(refresh_token)
AUTH_HEADER="Authorization: Bearer $TOKEN"

download_file "$APRIP_ARGS" "$APRIP_DESTINATION" "APRIP"
download_file "$APCIP_ARGS" "$APCIP_DESTINATION" "APCIP"
