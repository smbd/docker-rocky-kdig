ARG ROCKY_REL
FROM rockylinux/rockylinux:${ROCKY_REL} as builder

RUN dnf install -y 'dnf-command(config-manager)' && \
 dnf config-manager --set-enabled crb && \
 dnf install -y epel-release && \
 dnf install -y rpm-build rpmdevtools \
  autoconf automake gcc glibc-devel make pkgconf \
  'dnf-command(builddep)' createrepo && \
 rpmdev-setuptree

COPY rpmbuild/ /root/rpmbuild/

RUN if [ -f /root/rpmbuild/SRPMS/*.src.rpm ] ; then dnf builddep -y /root/rpmbuild/SRPMS/*src.rpm && rpmbuild --define "debug_package %{nil}" --rebuild /root/rpmbuild/SRPMS/*.src.rpm ; else dnf builddep -y /root/rpmbuild/SPECS/*.spec && rpmbuild --define "debug_package %{nil}" -ba /root/rpmbuild/SPECS/*.spec ; fi

RUN mkdir -p /tmp/knot
RUN cd /root/rpmbuild/RPMS/`uname -m` \
 && cp knot-libs-*.rpm knot-utils-*.rpm /tmp/knot

RUN createrepo /tmp/knot

ARG ROCKY_REL
FROM rockylinux/rockylinux:9.2-minimal

LABEL maintainer="Mitsuru Shimamura <smbd.jp@gmail.com>"

RUN mkdir -p /tmp/knot

COPY --from=builder /tmp/knot /tmp/knot

COPY knot.repo /etc/yum.repos.d/

RUN microdnf install -y knot-utils \
 && microdnf clean all

ENTRYPOINT ["/usr/bin/kdig"]
