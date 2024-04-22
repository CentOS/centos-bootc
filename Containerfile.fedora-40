# This container build uses some special features of podman that allow
# a process executing as part of a container build to generate a new container
# image "from scratch".
#
# This container build uses nested containerization, so you must build with e.g.
# podman build --security-opt=label=disable --cap-add=all --device /dev/fuse <...>
#
# # Why are we doing this?
#
# Today this base image build process uses rpm-ostree.  There is a lot of things that
# rpm-ostree does when generating a container image...but important parts include:
#
# - auto-updating labels in the container metadata
# - Generating "chunked" content-addressed reproducible image layers (notice
#   how there are ~60 layers in the generated image)
#
# The latter bit in particular is currently impossible to do from Containerfile.
# A future goal is adding some support for this in a way that can be honored by
# buildah (xref https://github.com/containers/podman/discussions/12605)
#
# # Why does this build process require additional privileges?
#
# Because it's generating a base image and uses containerbuildcontextization features itself.
# In the future some of this can be lifted.

FROM quay.io/fedora/fedora:40 as repos

FROM quay.io/centos-bootc/bootc-image-builder:latest as builder
ARG MANIFEST=fedora-bootc.yaml
COPY --from=repos /etc/dnf/vars /etc/dnf/vars
COPY --from=repos /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-* /etc/pki/rpm-gpg
# The input git repository has .repo files committed to git rpm-ostree has historically
# emphasized that.  But here, we are fetching the repos from the container base image.
# So copy the source, and delete the hardcoded ones in git, and use the container base
# image ones.  We can drop the ones commited to git when we hard switch to Containerfile.
COPY . /src
WORKDIR /src
RUN rm -vf /src/*.repo
COPY --from=repos /etc/yum.repos.d/*.repo /src
RUN --mount=type=cache,target=/workdir --mount=type=bind,rw=true,src=.,dst=/buildcontext,bind-propagation=shared rpm-ostree compose image \
 --image-config fedora-bootc-config.json --cachedir=/workdir --format=ociarchive --initialize ${MANIFEST} /buildcontext/out.ociarchive

FROM oci-archive:./out.ociarchive
# Need to reference builder here to force ordering. But since we have to run
# something anyway, we might as well cleanup after ourselves.
RUN --mount=type=bind,from=builder,src=.,target=/var/tmp --mount=type=bind,rw=true,src=.,dst=/buildcontext,bind-propagation=shared rm /buildcontext/out.ociarchive
