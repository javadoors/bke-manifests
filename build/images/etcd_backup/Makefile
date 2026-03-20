VERSION:=$(shell cat VERSION)
CPU_ARCH:=$(shell go env GOARCH)
REGISTRY:=registry.cn-hangzhou.aliyuncs.com/bocloud
BKE_REGISTRY ?= registry.bocloud.com:5001/kubernetes

RELEASE_IMG:=$(REGISTRY)/etcd-backup:${VERSION}
BKE_REGISTRY_IMG:=$(BKE_REGISTRY)/etcd-backup:${VERSION}

.PHONY: image
image:
ifeq (${CPU_ARCH},amd64)
	@echo "building amd64 image..."
	docker build -f ./amd64/Dockerfile -t $(RELEASE_IMG) .
	docker push $(RELEASE_IMG)
endif
ifeq (${CPU_ARCH},loong64)
	@echo "building loongarch64 image..."
	docker build -f ./loongarch64/Dockerfile -t deploy.bocloud/etcd/etcd-backup-loongarch64:v3.4.13 .
endif
ifeq (${CPU_ARCH},arm64)
	@echo "building aarch64 image..."
	docker build -f ./arm64/Dockerfile -t $(RELEASE_IMG) .
endif

.PHONY: build-amd64
build_amd64:
	@echo "building amd64 image..."
	docker build --platform linux/amd64 -f ./amd64/Dockerfile -t $(RELEASE_IMG) .
	docker push $(RELEASE_IMG)

.PHONY: build-arm64
build_arm64:
	@echo "building arm64 image..."
	docker build --platform linux/arm64 -f ./arm64/Dockerfile -t $(RELEASE_IMG) .
	docker push $(RELEASE_IMG)

.PHONY: build-loongarch64
build_loongarch64:
	@echo "building loongarch64 image..."
	docker build  --platform linux/loong64 -f ./loongarch64/Dockerfile -t $(RELEASE_IMG) .
	docker push $(RELEASE_IMG)

.PHONY: release
release:
	make build_amd64 RELEASE_IMG=$(RELEASE_IMG)-amd64
	make build_arm64 RELEASE_IMG=$(RELEASE_IMG)-arm64

	# make manifest
	@echo "make manifest..."
	docker manifest create $(RELEASE_IMG) $(RELEASE_IMG)-amd64 $(RELEASE_IMG)-arm64
	docker manifest annotate $(RELEASE_IMG) $(RELEASE_IMG)-amd64 --os linux --arch amd64
	docker manifest annotate $(RELEASE_IMG) $(RELEASE_IMG)-arm64 --os linux --arch arm64
	docker manifest push $(RELEASE_IMG)

	make migrate RELEASE_IMG=$(RELEASE_IMG)





.PHONY: migrate
migrate:
	@echo "migrate..."
	@bke registry sync  --src-tls-verify  --dest-tls-verify --source $(RELEASE_IMG) --target $(BKE_REGISTRY_IMG) --multi-arch