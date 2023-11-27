---
nav_order: 1
---

# Goals

This project's toplevel goal is to maintain default definitions for
base *bootable* container images, locked with Fedora ELN and CentOS Stream 9.

## Status

This is an in-development project not intended for production use yet.

## Container images

The primary output of this project is container images.  The current
main development targets are [Fedora ELN](https://docs.fedoraproject.org/en-US/eln/)
and CentOS Stream 9.

### Distribution locked images

These images are intended to exactly match the content of the underlying distribution.

- `quay.io/centos-bootc/fedora-bootc:eln`
- `quay.io/centos-bootc/centos-bootc:stream9`

### Layered images

There are also layered images; for more information on these, see
[the centos-bootc-layered repository](https://github.com/CentOS/centos-bootc-layered).

### Development images

Some components of this project move quickly, and it's often useful to see things
as they appear in git `main` instead of waiting for package releases.

The following images track git main of selected components:

- `quay.io/centos-bootc/fedora-bootc-dev:eln`
- `quay.io/centos-bootc/centos-bootc-dev:stream9`

For more information, see [the dev repository](https://github.com/centos/centos-bootc-dev).

## Trying it out

See [install.md](./install.md).

## Differences from Fedora CoreOS

Fedora CoreOS today is not small; there are multiple reasons for this, but
primarily because it was created in a pre-bootable-container time.  Not everyone
wants e.g. moby-engine.

But going beyond size, the images produced by this project will focus
on a container-native flow.  We will ship a (container) image that does not
include Ignition for example.

## Differences from RHEL CoreOS

We sometimes say that RHEL CoreOS
[has FCOS as an upstream](https://github.com/openshift/os/blob/master/docs/faq.md#q-what-is-coreos)
but this is only kind of true; RHEL CoreOS includes a subset of FCOS content,
and is lifecycled with OCP.

An explicit goal of this project is to produce bootable container images
that can be used as *base images* for RHEL CoreOS; for more on this, see e.g.
<https://github.com/openshift/os/issues/799>

## Differences from RHEL for Edge

It is an explicit goal that CentOS boot also becomes a "base input" to RHEL for Edge.

## Understanding "tiers"

There is a "tier-0" image, but it is not yet being automatically built.  The "tier-0"
contains:

- kernel
- systemd
- bootc
- selinux-policy-targeted

The tier-1 is a reasonably large system:

- NetworkManager, chrony
- openssh-server
- dnf (for installing packages in container builds)
- rpm-ostree (A lot of tooling uses this too)

The content set for these images is subject to change.

## Building

Here's an example command:

```shell
sudo rpm-ostree compose image --authfile ~/.config/containers/myquay.json --cachedir=cache -i --format=ociarchive centos-tier-0-stream9.yaml centos-tier-0-stream9.ociarchive
```

In some situations, copying to a local `.ociarchive` file is convenient. You
can also push to a registry with `--format=registry`.

More information at <https://coreos.github.io/rpm-ostree/container/>

## Badges

| Badge                   | Description          | Service      |
| ----------------------- | -------------------- | ------------ |
| [![Renovate][1]][2]     | Dependencies         | Renovate     |
| [![Pre-commit][3]][4]   | Static quality gates | pre-commit   |

[1]: https://img.shields.io/badge/renovate-enabled-brightgreen?logo=renovate
[2]: https://renovatebot.com
[3]: https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit
[4]: https://pre-commit.com/
