SRC_REPO=quay.io/jetstack/

DST_REPO=registry.cn-hangzhou.aliyuncs.com/bocloud/

VERSION=v1.11.0
#VERSION=v1.12.1

images= cert-manager-cainjector:$(VERSION) cert-manager-controller:$(VERSION) cert-manager-acmesolver:$(VERSION) cert-manager-webhook:$(VERSION)

ALL_ARCH=linux/amd64,linux/arm64

all:
	@for image in $(images); do \
		echo "FROM $(SRC_REPO)$${image}" > Dockerfile; \
		docker buildx build \
			-t $(DST_REPO)$${image} \
			--platform $(ALL_ARCH) \
			. \
			--push; \
	done