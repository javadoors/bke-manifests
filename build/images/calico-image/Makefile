#SRC_REPO=docker.io/calico/
SRC_REPO=registry.cn-hangzhou.aliyuncs.com/bocloud/
DST_REPO=deploy.bocloud.k8s:40443/kubernetes/

VERSION=v3.25.0

images= cni:$(VERSION) node:$(VERSION) kube-controllers:$(VERSION)

ALL_ARCH=linux/amd64,linux/arm64

all:
	@for image in $(images); do \
		echo "FROM $(SRC_REPO)$${image}" > Dockerfile; \
		docker buildx build \
			-t $(DST_REPO)calico-$${image} \
			--platform $(ALL_ARCH) \
			--progress plain \
			. \
			--push; \
	done

migrate:
	@for image in $(images); do \
  		docker pull $(SRC_REPO)$${image}; \
  		docker tag $(SRC_REPO)$${image} $(DST_REPO)calico-$${image}; \
		docker push $(DST_REPO)calico-$${image}; \
		docker rmi $(SRC_REPO)$${image}; \
		docker rmi $(DST_REPO)calico-$${image}; \
	done