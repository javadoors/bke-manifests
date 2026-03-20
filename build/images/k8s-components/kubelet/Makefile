CENTOS_IMAGE=centos:7

REPO=registry.cn-hangzhou.aliyuncs.com/bocloud
KUBELET_IMAGE_NAME=kubelet
KUBELET_VERSION=1.27.2
IMAGE_NAME=$(REPO)/$(KUBELET_IMAGE_NAME):v$(KUBELET_VERSION)

all: release

amd64:
	# docker building amd64 $(IMAGE_NAME)
	@docker build \
				--platform linux/amd64 \
        		--build-arg VERSION=$(KUBELET_VERSION) \
        		--build-arg BASEIMAGE=$(CENTOS_IMAGE)@sha256:dead07b4d8ed7e29e98de0f4504d87e8880d4347859d839686a31da35a3b532f \
        		--build-arg TARGETARCH="amd64" \
        		-t $(IMAGE_NAME) .

	@docker push $(IMAGE_NAME)
	# docker build amd64 $(IMAGE_NAME) success

arm64:
	# docker building arm64 $(IMAGE_NAME)
	@docker build \
        --platform linux/arm64 \
		--build-arg VERSION=$(KUBELET_VERSION) \
		--build-arg TARGETARCH=arm64 \
		--build-arg BASEIMAGE=$(CENTOS_IMAGE)@sha256:73f11afcbb50d8bc70eab9f0850b3fa30e61a419bc48cf426e63527d14a8373b \
		-t $(IMAGE_NAME) .

	@docker push $(IMAGE_NAME)
	# docker build arm64 $(IMAGE_NAME) success

build-arm64:
	# docker building $(IMAGE_NAME)-arm64
	@docker build \
		--platform linux/arm64 \
		--build-arg VERSION=$(KUBELET_VERSION) \
		--build-arg TARGETARCH=arm64 \
		--build-arg BASEIMAGE=$(CENTOS_IMAGE)@sha256:73f11afcbb50d8bc70eab9f0850b3fa30e61a419bc48cf426e63527d14a8373b \
		-t $(IMAGE_NAME)-arm64 .

	@docker push $(IMAGE_NAME)-arm64
	# docker build $(IMAGE_NAME)-arm64 success


build-amd64:
	# docker building $(IMAGE_NAME)-amd64
	@docker build \
			--platform linux/amd64 \
    		--build-arg VERSION=$(KUBELET_VERSION) \
    		--build-arg BASEIMAGE=$(CENTOS_IMAGE)@sha256:dead07b4d8ed7e29e98de0f4504d87e8880d4347859d839686a31da35a3b532f \
    		--build-arg TARGETARCH="amd64" \
    		-t $(IMAGE_NAME)-amd64 .

	@docker push $(IMAGE_NAME)-amd64
	# docker build $(IMAGE_NAME)-amd64 success

release:
	docker buildx build \
		-t $(IMAGE_NAME) \
		--platform linux/arm64,linux/amd64 \
		--progress plain \
		--build-arg VERSION=$(KUBELET_VERSION) \
		--build-arg BASEIMAGE=$(CENTOS_IMAGE) \
		. \
		--push


manifest:
	docker manifest create --insecure $(IMAGE_NAME) $(IMAGE_NAME)-arm64 $(IMAGE_NAME)-amd64
	docker manifest annotate $(IMAGE_NAME) $(IMAGE_NAME)-arm64 --os linux --arch arm64
	docker manifest annotate $(IMAGE_NAME) $(IMAGE_NAME)-amd64 --os linux --arch amd64
	docker manifest push --insecure $(IMAGE_NAME)
