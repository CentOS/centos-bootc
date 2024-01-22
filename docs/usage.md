---
nav_order: 3
---

# Operating system content and usage

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
recommended pattern to avoid this problem (nd is also somewhat of a best
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
