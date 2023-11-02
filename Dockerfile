ARG AUTOCONFVER=2.71
ARG PY310=3.10.13
ARG PY311=3.11.6
ARG PY312=3.12.0

FROM centos:7 as rpm_builder

RUN yum install -y epel-release rpmdevtools rpmlint && \
  rpmdev-setuptree

WORKDIR /root/rpmbuild

FROM rpm_builder as autoconf_builder

RUN yum groups mark install "Development Tools" && \
  yum groups mark convert "Development Tools" && \
  yum groupinstall -y "Development Tools"

ARG AUTOCONFVER
ADD http://ftp.gnu.org/gnu/autoconf/autoconf-${AUTOCONFVER}.tar.gz SOURCES/

COPY ./autoconf.spec SPECS/

RUN rpmbuild -bs SPECS/autoconf.spec && \
  rpmbuild -bb SPECS/autoconf.spec

RUN yum install -y /root/rpmbuild/RPMS/noarch/autoconf-2.71-1.noarch.rpm

FROM autoconf_builder as python_builder

COPY build-deps SPECS/
COPY ./el7-pkgconfig /el7-pkgconfig

RUN yum install -y $(cat SPECS/build-deps)

FROM python_builder as py310_builder

ARG PY310
COPY ./python3.10.spec SPECS/
ADD https://www.python.org/ftp/python/${PY310}/Python-${PY310}.tgz SOURCES/

ENV PKG_CONFIG_PATH /el7-pkgconfig

RUN rpmbuild -bs SPECS/python3.10.spec && \
  rpmbuild --noclean -bb SPECS/python3.10.spec

FROM python_builder as py311_builder

ARG PY311
COPY ./python3.11.spec SPECS/
ADD https://www.python.org/ftp/python/${PY311}/Python-${PY311}.tgz SOURCES/

ENV PKG_CONFIG_PATH /el7-pkgconfig

RUN rpmbuild -bs SPECS/python3.11.spec && \
  rpmbuild --noclean -bb SPECS/python3.11.spec

FROM python_builder as py312_builder

ARG PY312
COPY ./python3.12.spec SPECS/
ADD https://www.python.org/ftp/python/${PY312}/Python-${PY312}.tgz SOURCES/

ENV PKG_CONFIG_PATH /el7-pkgconfig

RUN rpmbuild -bs SPECS/python3.12.spec && \
  rpmbuild --noclean -bb SPECS/python3.12.spec

FROM scratch

COPY --from=autoconf_builder /root/rpmbuild/RPMS/*/*.rpm /root/rpmbuild/SRPMS/*.rpm /
COPY --from=python_builder /root/rpmbuild/RPMS/*/*.rpm /root/rpmbuild/SRPMS/*.rpm /
COPY --from=py310_builder /root/rpmbuild/RPMS/*/*.rpm /root/rpmbuild/SRPMS/*.rpm /
COPY --from=py311_builder /root/rpmbuild/RPMS/*/*.rpm /root/rpmbuild/SRPMS/*.rpm /
COPY --from=py312_builder /root/rpmbuild/RPMS/*/*.rpm /root/rpmbuild/SRPMS/*.rpm /