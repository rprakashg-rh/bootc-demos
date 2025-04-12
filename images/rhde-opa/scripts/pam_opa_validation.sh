#!/bin/bash

# Exit as soon as any step fails with non-zero return code
set -e 

# Get all groups current user belongs to
GROUPS=$(id -nG "$PAM_USER" | tr ' ' ',')

USER="$PAM_USER"
OPA_URL="http://localhost:8181/v1/data/authz/allow"

response=$(curl -s -X POST -H "Content-Type: application/json" \
  --data "{\"input\": {\"user\": \"$PAM_USER\", \"groups\": [\"${GROUPS//,/\",\"}\"]}}" $OPA_URL)

allowed=$(echo "$response" | jq -r '.result')

if [[ "$allowed" == "true" ]]; then
  exit 0
else
  exit 1
fi