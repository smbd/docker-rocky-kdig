# syntax=docker/dockerfile:1

ARG ROCKY_REL=9.3

FROM rockylinux/rockylinux:${ROCKY_REL} AS builder

ARG ROCKY_REL
ARG KNOT_VER=3.4.4

RUN --mount=type=cache,sharing=locked,target=/var/cache/yum \
 dnf groupinstall -y "Development Tools" \
 && dnf install -y wget 'dnf-command(builddep)' createrepo

COPY copr_repo/ /root/copr_repo/
COPY rpmbuild/ /root/rpmbuild/

RUN cd /root/rpmbuild/SOURCES/ && wget -q https://secure.nic.cz/files/knot-dns/knot-${KNOT_VER}.tar.xz

RUN if [ -f /root/rpmbuild/SRPMS/*.src.rpm ] ; then dnf --enablerepo=crb builddep -y /root/rpmbuild/SRPMS/*src.rpm && rpmbuild --define "debug_package %{nil}" --rebuild /root/rpmbuild/SRPMS/*.src.rpm ; else dnf --enablerepo=crb builddep -y /root/rpmbuild/SPECS/*.spec && rpmbuild --define "debug_package %{nil}" -ba /root/rpmbuild/SPECS/*.spec ; fi

RUN mkdir -p /tmp/knot
RUN cd /root/rpmbuild/RPMS/`uname -m` \
 && cp knot-libs-*.rpm knot-utils-*.rpm /tmp/knot

RUN createrepo /tmp/knot

FROM rockylinux/rockylinux:${ROCKY_REL}-minimal

COPY knot.repo /etc/yum.repos.d/

RUN --mount=type=bind,from=builder,source=/tmp/knot,target=/tmp/knot \
 microdnf install -y knot-utils

ENTRYPOINT ["/usr/bin/kdig"]
