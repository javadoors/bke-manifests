FROM alpine:latest


RUN alpine_version=`cat /etc/issue | head -1 | awk '{print $5}'` \
    && echo "https://mirrors.aliyun.com/alpine/v${alpine_version}/main/" > /etc/apk/repositories   \
    && apk update && apk upgrade


RUN apk add --no-cache \
            bash bash-doc bash-completion \
            curl \
            iproute2 \
            ethtool \
            busybox-extras \
            openssh-client \
            tcpdump \
            bind-tools \
            net-tools \
            conntrack-tools  \
            wget \
            busybox \
    && rm -rf /var/cache/apk/*

CMD ["/bin/bash"]