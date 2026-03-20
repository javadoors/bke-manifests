GO_VERSION ?= 1.19.4
GO_CONTAINER_IMAGE ?= docker.io/library/golang:$(GO_VERSION)
GOPROXY := https://goproxy.cn


# Active module mode, as we use go modules to manage dependencies
export GO111MODULE=on

TAG ?= v1.3.2
#ARCH := amd64

ALL_ARCH = amd64 arm64

REGISTRY ?= registry.cn-hangzhou.aliyuncs.com/bocloud
# control plane
KUBEADM_CONTROL_PLANE_IMAGE_NAME ?= kubeadm-control-plane-controller
KUBEADM_CONTROL_PLANE_CONTROLLER_IMG ?= $(REGISTRY)/$(KUBEADM_CONTROL_PLANE_IMAGE_NAME)


all: docker-build-kubeadm-control-plane docker-push-kubeadm-control-plane docker-push-manifest-kubeadm-control-plane

.PHONY: docker-build-kubeadm-control-plane-arch
docker-build-kubeadm-control-plane-arch: ## Build the docker image for kubeadm control plane controller manager
	DOCKER_BUILDKIT=1 docker build \
		--build-arg builder_image=$(GO_CONTAINER_IMAGE) \
		--build-arg goproxy=$(GOPROXY) \
		--build-arg ARCH=$(ARCH) \
		--build-arg package=./controlplane/kubeadm \
		--build-arg ldflags="$(LDFLAGS)" \
		. \
		-t $(KUBEADM_CONTROL_PLANE_CONTROLLER_IMG)-$(ARCH):$(TAG)



.PHONY: docker-build-kubeadm-control-plane
docker-build-kubeadm-control-plane: ## Build the docker image for kubeadm control plane controller manager
	for arch in $(ALL_ARCH); do \
		$(MAKE) docker-build-kubeadm-control-plane-arch ARCH="$${arch}"; \
	done


.PHONY: docker-push-kubeadm-control-plane
docker-push-kubeadm-control-plane: ## Push the docker image for kubeadm control plane controller manager
	for arch in $(ALL_ARCH); do \
		docker push $(KUBEADM_CONTROL_PLANE_CONTROLLER_IMG)-$${arch}:$(TAG); \
	done

.PHONY: docker-push-manifest-kubeadm-control-plane
docker-push-manifest-kubeadm-control-plane: ## Push the multiarch manifest for the kubeadm control plane docker images
	## Minimum docker version 18.06.0 is required for creating and pushing manifest images.
	docker manifest create --amend $(KUBEADM_CONTROL_PLANE_CONTROLLER_IMG):$(TAG) $(shell echo $(ALL_ARCH) | sed -e "s~[^ ]*~$(KUBEADM_CONTROL_PLANE_CONTROLLER_IMG)\-&:$(TAG)~g")
	@for arch in $(ALL_ARCH); do docker manifest annotate --arch $${arch} ${KUBEADM_CONTROL_PLANE_CONTROLLER_IMG}:${TAG} ${KUBEADM_CONTROL_PLANE_CONTROLLER_IMG}-$${arch}:${TAG}; done
	docker manifest push --purge $(KUBEADM_CONTROL_PLANE_CONTROLLER_IMG):$(TAG)