# centos-bootc

Create and maintain base *bootable* container images from Fedora ELN and
CentOS Stream packages.

The longer term vision of this project is that the build infrastructure
(and possibly some of the container definitions) move into the respective
upstream operating systems.  For now, this project acts as a more central
point for this across these distributions.

Current WIP documentation: <https://gitlab.com/bootc-org/fedora-bootc/docs>

## Motivation

The original Docker container model of using "layers" to model
applications has been extremely successful.  This project
aims to apply the same technique for bootable host systems - using
standard OCI/Docker containers as a transport and delivery format
for base operating system updates.

## Generated container images

At the moment the main image is `quay.io/centos-bootc/centos-bootc:stream9`

## Building

The build process is 95% just installing RPM content into a container
image; there is some non-RPM config files etc. in this repository
too.

See:

- [Containerfile.centos-stream9]
- [Containerfile.centos-stream10]
- [Containerfile.fedora-40]

For example:

```bash
podman build --security-opt=label=disable --cap-add=all --device /dev/fuse \
  -f Containerfile.centos-stream9 -t localhost/centos-bootc:stream9
```

NOTE: This will not work when using "podman machine" over the remote client
(e.g. the default on MacOS/Windows).
In order to do a build on MacOS/Windows, first:

`podman machine ssh`

Then, navigate to your source code directory:

`cd /path/to/source/code` (e.g. `/Users/chloe/src/centos-bootc`

And finally, invoke the same

`podman build ...`

per above.

There is also <https://gitlab.com/bootc-org/fedora-bootc/base-images-experimental>
for a new even more container-native build system.

## Badges

| Badge                   | Description          | Service      |
| ----------------------- | -------------------- | ------------ |
| [![Renovate][1]][2]     | Dependencies         | Renovate     |
| [![Pre-commit][3]][4]   | Static quality gates | pre-commit   |

[1]: https://img.shields.io/badge/renovate-enabled-brightgreen?logo=renovate
[2]: https://renovatebot.com
[3]: https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit
[4]: https://pre-commit.com/
