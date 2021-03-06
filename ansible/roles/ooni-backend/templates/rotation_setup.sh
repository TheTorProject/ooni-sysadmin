#!/bin/bash
# Managed by ansible, see roles/ooni-backend/tasks/main.yml
# Configure test-helper droplet
# This script is run as root and with CWD=/
set -euo pipefail
exec 1>setup.log 2>&1
echo > /etc/motd
echo "deb [trusted=yes] https://ooni-internal-deb.s3.eu-central-1.amazonaws.com unstable main" > /etc/apt/sources.list.d/ooni.list
cat <<EOF  | gpg --dearmor > /etc/apt/trusted.gpg.d/ooni.gpg
-----BEGIN PGP PUBLIC KEY BLOCK-----

mDMEYGISFRYJKwYBBAHaRw8BAQdA4VxoR0gSsH56BbVqYdK9HNQ0Dj2YFVbvKIIZ
JKlaW920Mk9PTkkgcGFja2FnZSBzaWduaW5nIDxjb250YWN0QG9wZW5vYnNlcnZh
dG9yeS5vcmc+iJYEExYIAD4WIQS1oI8BeW5/UhhhtEk3LR/ycfLdUAUCYGISFQIb
AwUJJZgGAAULCQgHAgYVCgkICwIEFgIDAQIeAQIXgAAKCRA3LR/ycfLdUFk+AQCb
gsUQsAQGxUFvxk1XQ4RgEoh7wy2yTuK8ZCkSHJ0HWwD/f2OAjDigGq07uJPYw7Uo
Ih9+mJ/ubwiPMzUWF6RSdgu4OARgYhIVEgorBgEEAZdVAQUBAQdAx4p1KerwcIhX
HfM9LbN6Gi7z9j4/12JKYOvr0d0yC30DAQgHiH4EGBYIACYWIQS1oI8BeW5/Uhhh
tEk3LR/ycfLdUAUCYGISFQIbDAUJJZgGAAAKCRA3LR/ycfLdUL4cAQCs53fLphhy
6JMwVhRs02LXi1lntUtw1c+EMn6t7XNM6gD+PXpbgSZwoV3ZViLqr58o9fZQtV3s
oN7jfdbznrWVigE=
=PtYb
-----END PGP PUBLIC KEY BLOCK-----
EOF
apt-get update -q
apt-get upgrade -qy
apt-get install -qy nginx-light
apt-get install -qy oohelperd
