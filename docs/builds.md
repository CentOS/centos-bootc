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

## Example repositories

The following git repositories have some useful examples:

- [coreos/layering-examples](https://github.com/coreos/layering-examples)
- [openshift/rhcos-image-layering-examples](https://github.com/openshift/rhcos-image-layering-examples/)
