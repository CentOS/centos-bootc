# Trying out development builds

---
nav_order: 2
---

<!--
## Booting directly from KVM guest image

There's a provisional KVM guest image uploaded here:

<https://fedorapeople.org/~walters/cloud-init-base-eln-20231029.qcow2.zst>

You can run it using e.g. [virt-install](https://github.com/virt-manager/virt-manager/blob/main/man/virt-install.rst#--cloud-init)
and in general all the same techniques that work the Fedora Cloud Base or the
RHEL KVM guest image.

Once you've booted this, use e.g. `bootc update` to fetch updates.
-->

## Rebasing from Fedora CoreOS

[Fedora CoreOS](https://docs.fedoraproject.org/en-US/fedora-coreos/) supports
many different platforms, and can be used as a starting point to "rebase" to a
custom derived image from CentOS boot.

```shell
systemctl mask --now zincati && rm -vf /run/ostree/staged-deployment-locked
echo "# dummy change" >> "/etc/sudoers.d/coreos-sudo-group"
rpm-ostree rebase ostree-unverified-registry:quay.io/centos-boot/fedora-tier-1:eln
systemctl reboot
```

See also [this pull request][1] for more information.

## TODO: Use osbuild

Document the ongoing work to materialize a disk image from a container.

## Using `bootc install-to-filesystem --replace=alongside` with a cloud image

A toplevel goal of this project is that the "source of truth" for Linux
operating system management is a container image registry - as opposed to e.g. a
set of qcow2 OpenStack images or AMIs, etc.

The latest development builds of `bootc` have support for
`bootc install-to-filesystem --replace=alongside`.  More about this core
mechanic in the [bootc install docs](https://github.com/containers/bootc/blob/main/docs/install.md).

Here's an example set of steps to execute; this could be done via e.g.
[cloud-init](https://cloudinit.readthedocs.io/en/latest/reference/index.html)
configuration.

```shell
dnf -y install podman skopeo
podman run --rm --privileged --pid=host -v /:/target --security-opt label=type:unconfined_t quay.io/centos-boot/fedora-tier-1:eln bootc install-to-filesystem --target-no-signature-verification --karg=console=ttyS0,115200n8 --replace=alongside /target
reboot
```

## Generating a derived container image

These examples just use a "stock" container image, and in the first case rely on
user state being preserved by the `rpm-ostree rebase`.

What's much more interesting is to generate a custom derived container image,
and target that instead.  For more information, see

- <https://github.com/coreos/layering-examples>
- <https://github.com/openshift/rhcos-image-layering-examples>

[1]: https://github.com/coreos/fedora-coreos-docs/pull/540
