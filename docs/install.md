---
nav_order: 2
---

# Trying out development builds

## No default user accounts

The default images produced do *not* include any default passwords or SSH keys.
There is a `root` user present, but its password is locked.

## Using the "generic cloud" image

Many people who just want to "try things out" will find it easiest to start
with [the cloud image](https://github.com/CentOS/centos-bootc-layered/tree/main/cloud).
(It's a separate container image because cloud-init does not work on every deployment
 target, and it also serves as an effective demonstration of layering)

The [bootc playground](https://github.com/vrothberg/bootc-playground) repository
helps automate this.

## Use bootc-image-builder

The [bootc-image-builder tool](https://github.com/osbuild/bootc-image-builder)
supports generating disk images, including injecting user accounts.

NOTE: this tool [does not yet work with centos stream 9](https://github.com/osbuild/bootc-image-builder/issues/20).

## Generating a raw disk image that can be launched via virt tooling

The above bootc-image-builder tool can generate disk images; however, a key part
of the idea of `bootc` is that operating system images that use it are their
own self-sufficient "baseline" installer.  So you can use this example:

<https://github.com/containers/bootc/blob/main/docs/install.md#using-bootc-install-to-disk---via-loopback>

to generate a raw disk image from the default container base image, or your own
without any external tooling.

If you choose not to include SSH keys or other credentials directly in your image,
a useful pattern can often be to use [systemd credentials](https://systemd.io/CREDENTIALS/)
to inject a SSH key for root.  The above page has this example for qemu:

```bash
-smbios type=11,value=io.systemd.credential.binary:tmpfiles.extra=$(echo "f~ /root/.ssh/authorized_keys 600 root root - $(ssh-add -L | base64 -w 0)" | base64 -w 0)
```

Unlike current bootc-image-builder, this flow works with current CentOS Stream 9.

## Installation using Anaconda

Tools like
[Anaconda](https://anaconda-installer.readthedocs.io/en/latest/intro.html)
support injecting configuration at image installation time, such as SSH keys and
passwords. This means that in contrast to what was said just before, it's
possible to directly install (and update from) an "unconfigured base image"
provided by this project.

Because a current development target for this project is [Fedora ELN](https://docs.fedoraproject.org/en-US/eln/),
which includes the latest support for `bootupd`, it's recommended to use
that ISO at this time.  The support for `ostreecontainer` does not
yet exist in CentOS Stream 9.

See [example.ks](example.ks) for an example Kickstart file. The
[virt-install --initrd-inject](https://github.com/virt-manager/virt-manager/blob/main/man/virt-install.rst#--initrd-inject)
helps inject kickstart for installation to virtual machines.

## Using `bootc install to-filesystem --replace=alongside` with a cloud image

A toplevel goal of this project is that the "source of truth" for Linux
operating system management is a container image registry - as opposed to e.g. a
set of qcow2 OpenStack images or AMIs, etc. You should not need to maintain
infrastructure to e.g. manage garbage collection or versioning of cloud (IaaS)
VM images.

The latest releases of `bootc` have support for
`bootc install to-filesystem --replace=alongside`. More about this core mechanic
in the
[bootc install docs](https://github.com/containers/bootc/blob/main/docs/install.md).

Here's an example set of steps to execute; this could be done via e.g.
[cloud-init](https://cloudinit.readthedocs.io/en/latest/reference/index.html)
configuration.

```shell
dnf -y install podman skopeo
podman run --rm --privileged --pid=host -v /:/target --security-opt label=type:unconfined_t <yourimage> bootc install to-filesystem --karg=console=ttyS0,115200n8 --replace=alongside /target
reboot
```

<!--
## Booting directly from KVM guest image

There's a provisional KVM guest image uploaded here:

<https://fedorapeople.org/~walters/cloud-init-base-eln-20231029.qcow2.zst>
-->

## Using `bootc install to-disk --via-loopback` to generate a raw disk image

```shell
truncate -s 10G myimage.raw
podman run --rm --privileged --pid=host --security-opt label=type:unconfined_t -v .:/output <yourimage> bootc install to-disk --via-loopback /output/myimage.raw
```

This disk image can then be launched in a virtualization tool.

## Rebasing from Fedora CoreOS

[Fedora CoreOS](https://docs.fedoraproject.org/en-US/fedora-coreos/) supports
many different platforms, and can be used as a starting point to "rebase" to a
custom derived image from CentOS boot.  These commands should all be invoked
as root.

```shell
systemctl mask --now zincati && rm -vf /run/ostree/staged-deployment-locked
echo "# dummy change" >> "/etc/sudoers.d/coreos-sudo-group"
cp -a ~core/.ssh/authorized_keys.d/ignition ~core/.ssh/authorized_keys
rpm-ostree rebase ostree-unverified-registry:quay.io/centos-bootc/fedora-bootc:eln
systemctl reboot
```
