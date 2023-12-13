---
nav_order: 3
---

# Configuring systems via container builds

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

## Example repositories

The following git repositories have some useful examples:

- [coreos/layering-examples](https://github.com/coreos/layering-examples)
- [openshift/rhcos-image-layering-examples](https://github.com/openshift/rhcos-image-layering-examples/)
