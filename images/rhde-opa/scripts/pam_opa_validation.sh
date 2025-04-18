#!/bin/bash

# SELinux needs to be set in permissive mode
# sudo setenforce 0

# Exit as soon as any step fails with non-zero return code
set -e 

#adding a back door for testing
if [[ "$PAM_USER" == "admin" ]]; then
  echo "Admin"
  exit 0
fi

# Get all groups current user belongs to
USER_GROUPS=$(id -nG "$PAM_USER" | tr ' ' ',')
OPA_URL="http://127.0.0.1:8181/v1/data/access/allow"

echo "Payload: {\"input\": {\"user\": \"$PAM_USER\", \"groups\": \"$USER_GROUPS\"}}"

response=$(/usr/bin/curl -X POST $OPA_URL -H "Content-Type: application/json" \
  --data "{\"input\": {\"user\": \"$PAM_USER\", \"groups\": \"$USER_GROUPS\"}}")

echo "Response: $response" 

allowed=$(echo "$response" | jq -r '.result')

if [[ "$allowed" == true ]]; then
  echo "Allowed"
  exit 0
else
  echo "Not allowed"
  exit 1
fi