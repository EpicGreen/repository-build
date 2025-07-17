#!/bin/bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/default.env"

# Check if gpg is installed
if ! command -v gpg &> /dev/null
then
    echo "gpg could not be found, please install it."
fi

# generate gpg key
gpg --batch --gen-key <<EOF
%no-protection
Key-Type: RSA
Key-Length: 2048
Name-Real: ${GPG_NAME}
Name-Email: ${GPG_EMAIL}
Expire-Date: 2026-06-30
EOF

#export gpg key
gpg --export -a "${GPG_NAME}" > "${GPG_KEYFILE}.pub"
gpg --output "${GPG_KEYFILE}.pgp" --export-secret-key "${GPG_EMAIL}"

# import gpg key into rpm
rpm --import ${GPG_KEYFILE}.pub

echo "%_signature gpg" >> ~/.rpmmacros
echo "%_gpg_name ${GPG_NAME}" >> ~/.rpmmacros
echo "%_gpg_path ~/.gnupg" >> ~/.rpmmacros
echo "%_gpgbin /usr/bin/gpg" >> ~/.rpmmacros
echo "%_gpg_digest_algo sha256" >> ~/.rpmmacros
echo "%_gpg_sign_cmd %{__gpg} --batch --yes --no-armor --local-user \"%{_gpg_name}\" --digest-algo \"%{_gpg_digest_algo}\" --sign --detach-sign --output \"%{__signature_filename}\" \"%{__plaintext_filename}\"' >> ~/.rpmmacros