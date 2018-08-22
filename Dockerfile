FROM centos:7

ARG BIND_PREFIX=/usr/local/named
ARG BIND_SYSDIR=/etc/named
ARG BIND_VERSION=9-12-2
ARG BIND_VERSION_DOT=9.12.2

COPY named.conf ${BIND_SYSDIR}/named.conf
COPY entrypoint.sh /entrypoint.sh

# install bind9
RUN yum install -y gcc make perl-devel openssl-devel mysql-devel wget gettext \
    && curl -L https://www.isc.org/downloads/file/bind-${BIND_VERSION}/?version=tar-gz -o /tmp/bind.tar.gz \
    && tar -zxvf /tmp/bind.tar.gz -C /tmp \
    && cd /tmp/bind-${BIND_VERSION_DOT} \
    && ./configure --prefix=${BIND_PREFIX} --sysconfdir=${BIND_SYSDIR} --with-dlz-mysql --enable-threads=no --enable-epoll --disable-chroot --enable-backtrace --enable-largefile --disable-ipv6 --with-openssl  --with-libxml2 \
    && make && make install \
    && cd /root && rm -rf /tmp/*

# generate conf
RUN ${BIND_PREFIX}/sbin/rndc-confgen -r /dev/urandom > ${BIND_SYSDIR}/rndc.conf \
    && tail -n 10 ${BIND_SYSDIR}/rndc.conf | head -n 9 | sed 's/#\ //g' > /tmp/tmp.conf \
    && sed -i '/#mark/r /tmp/tmp.conf' ${BIND_SYSDIR}/named.conf \
    && wget -O ${BIND_SYSDIR}/named.ca  http://www.internic.net/domain/named.root \
    && yum remove -y gcc make wget \
    && yum clean all

EXPOSE 53

ENTRYPOINT ["/entrypoint.sh"]
