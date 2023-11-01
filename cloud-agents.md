# Project Sagano tier-1 and cloud agents

The tier-0 and tier-1 images today do not contain any special
hypervisor-specific agents.  The following specifically are not included
for example:

- cloud-init
- vmware-guest-agent
- google-guest-agent
- qemu-guest-agent
- ignition
- afterburn

etc.

## Unnecessary on bare metal

For deployment to bare metal using e.g. Anaconda or `bootc install`, none of
these are necessary.

## Unnecessary for "immutable infrastructure" on hypervisors

A model we aim to emphasize is having the container image define the
"source of truth" for system state.  This conflicts with using e.g. `cloud-init`
and having it fetch instance metadata and raises questions around changes to the
instance metadata and when they apply.

Related to this, `vmware-guest-agent` includes a full "backdoor" mechanism to
log into the OS.

## Should be containerized anyways

In general particularly for e.g. `vmware-guest-agent`, it makes more sense to
containerize it.

## Easy to install afterward

Many of these (particularly the first ones mentioned) are easy to install in a
custom image.

You can build your own derived image that includes e.g. vmware-guest-agent if
required alongside all other desired customizations.

## Fully supported if installed

It is supported to include these agents in your image if desired (whether as
part of the base image or containerized).

## What about Ignition

Ignition as shipped by CoreOS Container Linux derivatives has a lot of
advantages in providing a model that works smoothly across both bare metal and
virtualized scenarios.

It also has some compelling advantages over cloud-init at a technical level.  

However, there is also significant overlap between a container-focused model of
the world and an Ignition-focused model.

More on this topic in [coreos.md](coreos.md).
