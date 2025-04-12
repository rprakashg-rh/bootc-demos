#!/bin/bash

# Exit as soon as any step fails with non-zero return code
set -e 

LINE='auth required pam_exec.so /usr/local/bin/pam_opa_check.sh'
FILE='/etc/pam.d/sshd'

grep -Fxq "$LINE" "$FILE" || echo "$LINE" >> "$FILE"
