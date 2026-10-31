#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
sudo install -m 644 nginx/kr2 /etc/nginx/sites-available/kr2
if ! sudo test -f /etc/ssl/private/kr2.key; then
  sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/kr2.key \
    -out /etc/ssl/certs/kr2.crt \
    -subj '/CN=notes.devops.local' \
    -addext 'subjectAltName=DNS:notes.devops.local'
fi
sudo chown root:root /etc/ssl/private/kr2.key
sudo chmod 600 /etc/ssl/private/kr2.key
sudo chmod 644 /etc/ssl/certs/kr2.crt
sudo ln -sfn /etc/nginx/sites-available/kr2 /etc/nginx/sites-enabled/kr2
sudo nginx -t
sudo systemctl reload nginx
