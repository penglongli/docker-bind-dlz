FROM centos:7

ARG BIND_PREFIX=/usr/local/named
ARG BIND_SYSDIR=/etc/named
ARG BIND_VERSION=9-12-2
ARG BIND_VERSION_DOT=9.12.2

COPY start.sh /
COPY named.conf ${BIND_SYSDIR}/named.conf.template
COPY entrypoint.sh /entrypoint.sh
COPY statistics.conf /statistics.conf

# install bind9
RUN yum install -y gcc make perl-devel openssl-devel mysql-devel libxml2-devel wget gettext sysvinit-tools  \
    && curl -L https://www.isc.org/downloads/file/bind-${BIND_VERSION}/?version=tar-gz -o /tmp/bind.tar.gz \
    && tar -zxvf /tmp/bind.tar.gz -C /tmp \
    && cd /tmp/bind-${BIND_VERSION_DOT} \
    && ./configure --prefix=${BIND_PREFIX} --sysconfdir=${BIND_SYSDIR} --with-dlz-mysql --enable-threads=no --enable-epoll --disable-chroot --enable-backtrace --enable-largefile --disable-ipv6 --with-openssl  --with-libxml2 \
    && make && make install \
    && cd /root && rm -rf /tmp/*

# generate conf
RUN ${BIND_PREFIX}/sbin/rndc-confgen -r /dev/urandom > ${BIND_SYSDIR}/rndc.conf \
    && tail -n 10 ${BIND_SYSDIR}/rndc.conf | head -n 9 | sed 's/#\ //g' > /tmp/tmp.conf \
    && sed -i '/#rndc/r /tmp/tmp.conf' ${BIND_SYSDIR}/named.conf.template \
    && wget -O ${BIND_SYSDIR}/named.ca  http://www.internic.net/domain/named.root \
    && mkdir ${BIND_SYSDIR}/acl && touch ${BIND_SYSDIR}/acl/acl.conf \
    && mkdir ${BIND_SYSDIR}/view && touch ${BIND_SYSDIR}/view/view.conf \
    && yum remove -y gcc make wget \
    && yum clean all \
# change timezone and locale
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'LANG="en_US.UTF-8"' > /etc/locale.conf

EXPOSE 53/TCP 53/UDP 953 8053

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/start.sh"]
