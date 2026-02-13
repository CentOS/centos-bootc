---
nav_order: 1
---

# Goals

This project's toplevel goal is to maintain default definitions for
base *bootable* container images, locked with Fedora ELN and CentOS Stream 9.

## Documentation

For comprehensive documentation on bootc, please see the **[Fedora bootc documentation](https://docs.fedoraproject.org/en-US/bootc/)**.

## Status

This repository is archived. Development has moved to [gitlab.com/redhat/centos-stream/containers/bootc](https://gitlab.com/redhat/centos-stream/containers/bootc).

## Container images

The primary output of this project is container images. The current
main development targets are [Fedora ELN](https://docs.fedoraproject.org/en-US/eln/)
and CentOS Stream 9.

### Distribution locked images

These images are intended to exactly match the content of the underlying distribution.

- `quay.io/centos-bootc/fedora-bootc:eln`
- `quay.io/centos-bootc/centos-bootc:stream9`

### Layered images

There are also layered images; for more information on these, see
[the centos-bootc-layered repository](https://gitlab.com/bootc-org/centos-bootc-layered).

## Badges

| Badge                   | Description          | Service      |
| ----------------------- | -------------------- | ------------ |
| [![Renovate][1]][2]     | Dependencies         | Renovate     |
| [![Pre-commit][3]][4]   | Static quality gates | pre-commit   |

[1]: https://img.shields.io/badge/renovate-enabled-brightgreen?logo=renovate
[2]: https://renovatebot.com
[3]: https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit
[4]: https://pre-commit.com/
