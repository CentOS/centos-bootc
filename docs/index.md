# Goals

This project's toplevel goal is to maintain default definitions for
base *bootable* container images, locked with Fedora ELN and CentOS Stream 9.

## Status

This is an in-development project not intended for production use yet.

## Container images

The primary output of this project is container images.  The current
main development target is [Fedora ELN](https://docs.fedoraproject.org/en-US/eln/)
and there is one image built:

- `quay.io/centos-boot/fedora-tier-1:eln`

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
