---
nav_order: 4
---

# This document has moved

See <https://bootc-org.gitlab.io/documentation/>

---
---

## Relationship with other projects

## Fedora CoreOS

The primary focus of Fedora CoreOS is on being a "golden image" that
can be configured via Ignition to run containers.  In the Fedora CoreOS
model, the OS is "lifecycled" separately from the workload and configuration.

This project is explicitly designed to be derived from via container
tooling, not Ignition.  While we will support a "just run the golden image" flow,
ading and customizing the base image with extra packages and content is the expected
norm.  An important corrollary to this is that OS updates are "lifecycled" with the
workload and configuration.

## RHEL CoreOS

We sometimes say that RHEL CoreOS
[has FCOS as an upstream](https://github.com/openshift/os/blob/master/docs/faq.md#q-what-is-coreos)
but this is only kind of true; RHEL CoreOS includes a subset of FCOS content,
and is lifecycled with OCP.

An explicit goal of this project is to produce bootable container images
lifecycled with the base OS, that can be used as *base images* for RHEL CoreOS.
For more on this, see e.g.
<https://github.com/openshift/os/issues/799>

## RHEL for Edge

It is an explicit goal that CentOS boot also becomes a "base input" to RHEL for Edge.
