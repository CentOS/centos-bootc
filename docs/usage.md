---
nav_order: 3
---

# This document has moved

See <https://bootc-org.gitlab.io/documentation/>

---
---

## Operating system content and usage

## Configuring systemd units

To add a custom systemd unit:

```dockerfile
COPY mycustom.service /usr/lib/systemd/system
RUN ln -s mycustom.service /usr/lib/systemd/system/default.target.wants
```

It will *not* work currently to do `RUN systemctl enable mycustom.service` instead
of the second line - unless you also write a
[systemd preset file](https://www.freedesktop.org/software/systemd/man/latest/systemd.preset.html)
enabling that unit.

### Static enablement versus presets

systemd presets are designed for "run once" semantics - thereafter, OS upgrades
won't cause new services to start.  In contrast, "static enablement" by creating
the symlink (as is done above) bypasses the preset logic.

In general, it's recommended to follow the "static enablement" approach because
it more closely aligns with "immutable infrastructure" model.

### Using presets

If nevertheless you want to use presets instead of "static enablement", one
recommended pattern to avoid this problem (and is also somewhat of a best
practice anyways) is to use a common prefix (e.g. `examplecorp-` for all of your
custom systemd units), resulting in `examplecorp-checkin.service`,
`examplecorp-agent.service` etc.

Then you can write a single systemd preset file to e.g.
`/usr/lib/systemd/system-preset/50-examplecorp.preset` that contains:

```systemd
enable examplecorp-*
```

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

This is useful for environments where manually updating the systems is
preferred, or having another tool perform schedule and execute the
updates, e.g. Ansible.

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

## Air-gapped and dissconnected updates

For environments without a direct connection to a centralized container
registry, we encourage mirroring an on-premise registry if possible or manually
moving container images using `skopeo copy`.
See [this blog](https://www.redhat.com/sysadmin/manage-container-registries)
for example.

For systems that require manual updates via USB drives, this procedure
describes how to use `skopeo` and `bootc switch`.

Copy image to USB Drive:

```skopeo copy docker://[registry]/[path to image] dir://run/media/$USER/$DRIVE/$DIR```

*note, Using the dir transport will create a number of files,
and it's recommended to place the image in it's own directory.
If the image is local the containers-storage transport will transfer
the image from a system directly to the drive:

```skopeo copy containers-storage:[image]:[tag] dir://run/media/$USER/$DRIVE/$DIR```

From the client system, insert the USB drive and mount it:

```mount /dev/$DRIVE /mnt```

`bootc switch` will direct the system to look at this mount point for future
updates, and is only necessary to run one time if you wish to continue
consuming updates from USB devices. note that if the mount point changes,
simply run this command to point to the alternate location. We recommend
using the same location each time to simplfy this.

```bootc switch --transport dir /mnt/$DIR```

Finally `bootc upgrade` will 1) check for updates and 2) reboot the system
when --apply is used.

```bootc upgrade --apply```

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
