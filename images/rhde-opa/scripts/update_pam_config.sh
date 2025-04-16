#!/bin/bash

# Exit as soon as any step fails with non-zero return code
set -e 

LINE='auth required pam_exec.so debug /usr/local/bin/pam_opa_validation.sh'
FILE='/etc/pam.d/sshd'

grep -Fxq "$LINE" "$FILE" || echo "$LINE" >> "$FILE"
