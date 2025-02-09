# syntax=docker/dockerfile:1

ARG ROCKY_REL=9.3

FROM rockylinux/rockylinux:${ROCKY_REL}-minimal

ARG KNOT_VER=3.4.4

COPY copr-knot.repo /etc/yum.repos.d/

RUN --mount=type=cache,sharing=locked,target=/var/cache/yum \
 microdnf install -y knot-utils-${KNOT_VER}

ENTRYPOINT ["/usr/bin/kdig"]
