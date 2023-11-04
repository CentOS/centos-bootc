#!/bin/bash
set -xeuo pipefail

pkginstall() {
    dnf -y install "$@"
}

pkginstall dnf-utils
dnf config-manager --set-enabled crb
# Sadly there's no EPEL for s390x so we just hardcode this for now, it's noarch.
dnf -y install https://kojipkgs.fedoraproject.org//packages/distribution-gpg-keys/1.98/1.el9/noarch/distribution-gpg-keys-1.98-1.el9.noarch.rpm

# rpm-ostree for builds, and need skopeo to do the container backend
pkginstall rpm-ostree skopeo
# For derived container builds
pkginstall buildah
# And a rust toolchain
pkginstall cargo openssl-devel

# Build tools
pkginstall selinux-policy-targeted osbuild crypto-policies-scripts sudo
