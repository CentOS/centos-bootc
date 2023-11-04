# This image contains the baseline tools to build bootable base images.
FROM quay.io/centos/centos:stream9
COPY coreos-continuous.repo /etc/yum.repos.d
COPY . /src
RUN /src/build.sh && cd / && rm /src -rf
