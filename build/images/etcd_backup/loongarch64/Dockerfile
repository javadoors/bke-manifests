FROM debian:10.4

RUN mkdir /etcd-backup

COPY backup.sh /etcd-backup/

COPY /loongarch64/etcdctl /usr/local/bin/

RUN chmod +x /usr/local/bin/etcdctl

WORKDIR /etcd-backup

ENTRYPOINT ["bash","backup.sh"]
