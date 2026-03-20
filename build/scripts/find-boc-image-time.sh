#!/bin/bash

version='boc4.0'
repository=192.168.2.191:5000 #'deploy.bocloud.k8s:40443'
HTTP='http'

image_categorys=(boc boc-clairctl boc-kubewatch bocloud-base bocloud-route bocloud-task license-server paas-shared paas-web-boc paas-upms-tree)

for image_category in ${image_categorys[*]}
do
    tags_json=$(curl -s -k -X GET $HTTP://$repository/v2/$version/$image_category/tags/list |jq -r .tags?)
    if [ -z "$tags_json" ];
    then
        echo "$repository/$version/$image_category"
    else
        tag=$(echo "$tags_json"|jq -r .[]? |grep amd64|sort -nr|head -n 1)
        echo "$repository/$image_category:$tag"

        tag=$(echo "$tags_json"|jq -r .[]? |grep arm64|sort -nr|head -n 1)
        echo "$repository/$image_category:$tag"

        tag=$(echo "$tags_json"|jq -r .[]? |grep amd64|sort -nr|head -n 1)
        # echo "$repository/$image_category:$tag"
        export name="$image_category"
        export tag=$tag
        j2 template.j2

    fi

done

