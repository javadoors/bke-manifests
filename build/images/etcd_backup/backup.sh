count=`echo $ENDPOINTS |tr -cd , |wc -c`
i=0
while [ $i -le $count ]
do
i=`expr $i + 1`
ENDPOINT=`echo $ENDPOINTS|cut -d"," -f$i`
etcdctl --endpoints=${ENDPOINT} --cacert=/etc/kubernetes/pki/etcd/etcd-ca --cert=/etc/kubernetes/pki/etcd/etcd-cert --key=/etc/kubernetes/pki/etcd/etcd-key endpoint health
if [ $? == 0 ]; then
etcdctl --endpoints=${ENDPOINT} --cacert=/etc/kubernetes/pki/etcd/etcd-ca --cert=/etc/kubernetes/pki/etcd/etcd-cert --key=/etc/kubernetes/pki/etcd/etcd-key snapshot save /backup/etcd-snapshot-$(date +%Y-%m-%d_%H-%M-%S_%Z).db
break
else
echo "***try another endpoint***"
fi
done

fileCount=`ls -l /backup/ |grep "^-"|wc -l`
if [ $RESERVEDNUM -lt $fileCount ]; then
    RESERVEDNUM=`expr $RESERVEDNUM + 1`
    rm `ls -t /backup/* |  tail -n +${RESERVEDNUM}`
fi
