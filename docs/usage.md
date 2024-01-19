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
