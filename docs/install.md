---
nav_order: 2
---

# Trying out development builds

Before you build a [derived container image](https://gitlab.com/bootc-org/examples),
you may want to just get a feel for the system, try out `bootc`, etc.  The bootable
container images produced by this project are intended to be deployable in every
physical and virtual environment that is supported by CentOS Stream 9 today.

First, an important note to understand: the generic base container images
do *not* include any default passwords or SSH keys.

## Local virtualization (Linux & MacOS)

### podman desktop plugin (currently MacOS only)

There is a
[podman desktop extension](https://github.com/containers/podman-desktop-extension-bootc)
dedicated to this.

### podman-bootc-cli

A new [podman-bootc-cli tool](https://gitlab.com/bootc-org/podman-bootc-cli)
project offers a dedicated and streamlined CLI interface for running images, and
in the future, it will become the backend for the podman desktop plugin.

### bootc-image-builder

The
[bootc-image-builder tool](https://github.com/osbuild/bootc-image-builder)
supports generating local-virtualization ready types such as `qcow2` and `.raw`
from the bootable container image.

### The dedicated cloud-init image

Many people who just want to "try things out" will find it easiest to start
with
[the cloud image](https://gitlab.com/bootc-org/centos-bootc-layered/-/tree/main/cloud).
It's a separate container image because cloud-init does not work on every deployment
target, and it also serves as an effective demonstration of layering.

## Production-oriented physical installation

This project uses the same
[Anaconda](https://anaconda-installer.readthedocs.io/en/latest/intro.html)
installer as the package-based CentOS.  Here's an example kickstart:

```text
# Basic setup
text
network --bootproto=dhcp --device=link --activate
# Basic partitioning
clearpart --all --initlabel --disklabel=gpt
reqpart --add-boot
part / --grow --fstype xfs

# Here's where we reference the container image to install - notice the kickstart
# has no `%packages` section!  What's being installed here is a container image.
ostreecontainer --url quay.io/centos-bootc/centos-bootc:stream9 --no-signature-verification

firewall --disabled
services --enabled=sshd

# Only inject a SSH key for root
rootpw --iscrypted locked
sshkey --username root "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOQkQHeKan3X+g1jILw4a3KtcfEIED0kByKGWookU7ev walters+2015-general@verbum.org"
reboot
```

## Production-oriented cloud virtualization

### Generating AMIs, ISO and qcow2 (and more)

The [bootc-image-builder tool](https://github.com/osbuild/bootc-image-builder)
which supports `.qcow2` usable in OpenStack/libvirt etc. also supports generating
Amazon Machine Images, and other production-oriented IaaS formats as well as a
self-installing ISO.  For more, please see the docs for that project.

After a disk image is generated, further updates will come from the container image.

### Replacing existing cloud images

A toplevel goal of this project is that the "source of truth" for Linux
operating system management is a container image registry - as opposed to e.g. a
set of qcow2 OpenStack images or AMIs, etc.  Generating cloud disk images
gives fast boots into the target container image state, but also requires
maintaining  infrastructure to e.g. manage garbage collection or versioning of
these images.

The latest releases of `bootc` have support for
`bootc install to-filesystem --replace=alongside`. More about this core mechanic
in the
[bootc install docs](https://github.com/containers/bootc/blob/main/docs/install.md).

Here's an example set of steps to execute; this could be done via e.g.
[cloud-init](https://cloudinit.readthedocs.io/en/latest/reference/index.html)
configuration.

```shell
dnf -y install podman skopeo
podman run --rm --privileged --pid=host -v /:/target -v /var/lib/containers:/var/lib/containers --security-opt label=type:unconfined_t <yourimage> bootc install to-filesystem --karg=console=ttyS0,115200n8 --replace=alongside /target
reboot
```
