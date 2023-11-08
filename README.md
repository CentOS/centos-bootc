# centos-boot

Create and maintain base *bootable* container images from Fedora ELN and
CentOS Stream packages.

The longer term vision of this project is that the build infrastructure
(and possibly some of the container definitions) move into the respective
upstream operating systems.  For now, this project acts as a more central
point for this across these distributions.

## Motivation

The original Docker container model of using "layers" to model
applications has been extremely successful.  This project
aims to apply the same technique for bootable host systems - using
standard OCI/Docker containers as a transport and delivery format
for base operating system updates.

## More information

See the [project documentation](https://centos.github.io/centos-boot/).
