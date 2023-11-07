# This image contains the baseline tools to build bootable base images.
FROM quay.io/centos/centos:stream9@sha256:c1768e42666a0b8953636b7d2636f0156814bc930dbd722a7da8d3985ae3da8a
COPY coreos-continuous.repo /etc/yum.repos.d
COPY . /src
RUN /src/build.sh && cd / && rm /src -rf
