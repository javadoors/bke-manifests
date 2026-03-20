ARG BASEIMAGE

FROM ${BASEIMAGE}

ARG VERSION
ARG TARGETARCH

COPY Centos-Base-${TARGETARCH}.repo /root/Centos-Base.repo
COPY modprobe.sh /usr/local/bin/modprobe

RUN mkdir -p /etc/yum.repos.d/bak \
    && mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak/ \
    && cp /root/Centos-Base.repo /etc/yum.repos.d/ \
    && yum clean all \
    && yum makecache

RUN yum install -y  \
    kubelet-${VERSION} \
    nfs-utils \
    ca-certificates \
    wget

CMD ["bash"]