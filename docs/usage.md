---
nav_order: 3
---

# Operating system content and usage

## Automatic updates enabled by default

The base image here enables the
[bootc-fetch-apply-updates.service](https://github.com/containers/bootc/blob/main/manpages-md-extra/bootc-fetch-apply-updates.service.md)
systemd unit which automatically finds updated container images from the
registry and will reboot into them.

### Controlling automatic updates

First, one can disable the timer entirely as part of a container build:

```dockerfile
RUN systemctl mask bootc-fetch-apply-updates.timer
```

Alternatively, one can use systemd "drop-ins" to override the timer
(for example, to schedule updates for once a week), create a file
like this, named e.g. `50-weekly.conf`:

```systemd
[Timer]
# Clear previous timers
OnBootSec= OnBootSec=1w OnUnitInactiveSec=1w
```

Then add it into your container:

```dockerfile
RUN mkdir -p /usr/lib/systemd/system/bootc-fetch-apply-updates.timer.d
COPY 50-weekly.conf /usr/lib/systemd/system/bootc-fetch-apply-updates.timer.d
```

## Filesystem interaction and layout

At "build" time, this image runs the same as any other OCI image where
the default filesystem setup is an `overlayfs` for `/` that captures all
changes written - to anywhere.

However, the default runtime (when booted on a virtual or physical host system,
with systemd as pid 1) there are some rules around persistence and writability.

The reason for this is that the primary goal is that base operating system
changes (updating kernels, binaries, configuration) are managed in your container
image and updated via `bootc upgrade`.

In general, aim for most content in your container image to be underneath
the `/usr` filesystem.  This is mounted read-only by default, and this
matches many other "immutable infrastructure" operating systems.

The `/etc` filesystem defaults to persistent and writable - and is the expected
place to put machine-local state (static IP addressing, hostnames, etc).

All other machine-local persistent data should live underneath `/var` by default;
for example, the default is for systemd to persist the journal to `/var/log/journal`.

### Understanding `root.transient``

At a technical level today, the base image uses the
[bootc](https://github.com/containers/bootc) project, which uses
[ostree](https://github.com/ostreedev/ostree) as a backend. However, unlike many
other ostree projects, this base image enables the `root.transient` feature from
[ostree-prepare-root](https://github.com/ostreedev/ostree/blob/main/man/ostree-prepare-root.xml#L121).

This has two primary effects:

- Content placed underneath `/var` at container build time is moved t
  `/usr/share/factory/var`, and on firstboot, updated files are handled via a
  systemd `tmpfiles.d` rule that copies new files (see
  `/usr/lib/tmpfiles.d/ostree-tmpfiles.conf`)
- The default `/` filesystem is writable, but not persistent. All content added
  in the container image in other toplevel directories (e.g. `/opt`) will be
  refreshed from the new container image on updates, and any modifications will
  be lost.
