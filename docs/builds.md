---
nav_order: 3
---

# This document has moved

See <https://bootc-org.gitlab.io/documentation/>

---
---

## Configuring systems via container builds

A key part of the idea of this project is that every tool and technique
one knows for building application container images should apply
to building bootable host systems.

Most configuration for a Linux system boils down to writing a file (`COPY`)
or executing a command (`RUN`).

## Embedding application containers

A common pattern is to add "application" containers that have references
embedded in the bootable host container.

For example, one can use the [podman systemd](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
configuration files, embedded via a container build instruction:

```dockerfile
FROM <base>
COPY foo.container /usr/share/containers/systemd
```

In this model, the application containers will be fetched and run on firstboot.
A key choice is whether to refer to images by digest, or by tag.  Referring
to images by digest ensures repeatable deployments, but requires shipping
host OS updates to update the workload containers.  Referring to images
by tag allows you to use other tooling to dynamically update the workload
containers.

## Users and groups

### Generic images

A common use case is to produce "generic" or "unconfigured" images that
don't have any hardcoded passwords or SSH keys and allow the end user to
inject them.  Per the [install doc](install.md) this is how the primary base
image produced by this project works.  Adding `cloud-init` into your image
works across many (but not all) environments.

Another pattern is to add users only when generating a disk image (not
in the container image); this is used by [bootc-image-builder](https://github.com/osbuild/bootc-image-builder).

### Injecting users at build time

However, some use cases really want an opinionated default authentication
story.

This is a highly complex topic.  The short version is that instead of invoking
e.g. `RUN useradd someuser` in a container build (or indirectly via an RPM
`%post` script), you should use[sysusers.d](https://www.freedesktop.org/software/systemd/man/latest/sysusers.d.html#).

(Even better, if this is for code executed as part of a systemd unit, investigate
 using `DynamicUser=yes`)

However, `sysusers.d` only works for "system" users, not human login users.

There is also [systemd JSON user records](https://systemd.io/USER_RECORD/)
which can be put into a container image; however at the time of this
writing while a `sshAuthorizedKeys` field exists, it is not synchronized
directly in a way that the SSH daemon can consume.

It is likely that at some point in the future the operating system upgrade logic
(bootc/ostree) will learn to just automatically reconcile changes to `/etc/passwd`.

At the current time, a workaround is to include a systemd unit which automatically
reconciles things at boot time, via e.g.

```text
ExecStart=/bin/sh -c 'getent someuser || useradd someuser'
```

For SSH keys, one approach is to hardcode the SSH authorized keys under `/usr`
so it's part of the clearly immutable state:

```dockerfile
RUN echo 'AuthorizedKeysFile /usr/etc-system/%u.keys' >> /etc/ssh/sshd_config.d/30-auth-system.conf && \
    echo 'ssh-ed25519 AAAAC3Nza... root@example.com' > /usr/etc-system/root.keys && chmod 0600 /usr/etc-system/root.keys
```

Finally of course at scale, often one will want to have systems configured
to use the network as source of truth for authentication, using e.g. [FreeIPA](https://www.freeipa.org/).
That avoids the need to hardcode any users or keys in the image, just the
setup necessary to contact the IPA server.

### Avoiding home directory persistence

In a default installation, the `/root` and `/home` directories are persistent,
and are symbolic links to `/var/roothome` and `/var/home` respectively. This
persistence is typically highly desirable for machines that are somewhat "pet"
like, from desktops to some types of servers, and often undesirable for
scale-out servers and edge devices.

It's recommended for most use cases that don't want a persistent home
directory to inject a systemd unit like this for both these directories,
that uses [tmpfs](https://www.kernel.org/doc/html/latest/filesystems/tmpfs.html):

```systemd
[Unit]
Description=Create a temporary filesystem for /var/home
DefaultDependencies=no
Conflicts=umount.target
Before=local-fs.target umount.target
After=swap.target

[Mount]
What=tmpfs
Where=/var/home
Type=tmpfs
```

If your systems management tooling discovers SSH keys dynamically
on boot (cloud-init, afterburn, etc.) this helps ensure that there's fewer
conflicts around "source of truth" for keys.

### Usage of `ostree container commit`

While you may find `RUN ostree container commit` as part of some
container builds, specifically this project aims to use
`root.transient` which obviates most of the incompatibility
detection done in that command.

In other words it's not needed and as of recently does very little.  We are likely
to introduce a new static-analyzer type process with a different name
and functionality in the future.

## Example repositories

The following git repositories have some useful examples:

- [centos-boot-examples](https://gitlab.com/CentOS/cloud/centos-boot-examples)
- [coreos/layering-examples](https://github.com/coreos/layering-examples)
- [openshift/rhcos-image-layering-examples](https://github.com/openshift/rhcos-image-layering-examples/)
