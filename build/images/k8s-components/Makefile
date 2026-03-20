SRC_REPO=registry.aliyuncs.com/google_containers

DST_REPO=deploy.bocloud.com:40443/kubernetes

K8S_VERSION=1.27.1

COMPONENTS_WORK_DIR=components
KUBELET_WORK_DIR=kubelet

all: release

amd64: check_docker
	cd $(KUBELET_WORK_DIR) && make amd64 KUBELET_VERSION=$(K8S_VERSION) REPO=$(DST_REPO)
	cd $(COMPONENTS_WORK_DIR) && make amd64 K8S_VERSION=$(K8S_VERSION) DST_REPO=$(DST_REPO) SRC_REPO=$(SRC_REPO)

arm64: check_docker
	cd $(KUBELET_WORK_DIR) && make arm64 KUBELET_VERSION=$(K8S_VERSION) REPO=$(DST_REPO)
	cd $(COMPONENTS_WORK_DIR) && make arm64 K8S_VERSION=$(K8S_VERSION) DST_REPO=$(DST_REPO) SRC_REPO=$(SRC_REPO)

release: init_buildx
	cd $(KUBELET_WORK_DIR) && make release KUBELET_VERSION=$(K8S_VERSION) REPO=$(DST_REPO)
	cd $(COMPONENTS_WORK_DIR) && make release K8S_VERSION=$(K8S_VERSION) DST_REPO=$(DST_REPO) SRC_REPO=$(SRC_REPO)

build-amd64: check_docker
	cd $(KUBELET_WORK_DIR) && make build-amd64 KUBELET_VERSION=$(K8S_VERSION) REPO=$(DST_REPO)
	cd $(COMPONENTS_WORK_DIR) && make build-amd64 K8S_VERSION=$(K8S_VERSION) DST_REPO=$(DST_REPO) SRC_REPO=$(SRC_REPO)

build-arm64: check_docker
	cd $(KUBELET_WORK_DIR) && make build-arm64 KUBELET_VERSION=$(K8S_VERSION) REPO=$(DST_REPO)
	cd $(COMPONENTS_WORK_DIR) && make build-arm64 K8S_VERSION=$(K8S_VERSION) DST_REPO=$(DST_REPO) SRC_REPO=$(SRC_REPO)

manifest: check_docker
	cd $(KUBELET_WORK_DIR) && make manifest KUBELET_VERSION=$(K8S_VERSION) REPO=$(DST_REPO)
	cd $(COMPONENTS_WORK_DIR) && make manifest K8S_VERSION=$(K8S_VERSION) DST_REPO=$(DST_REPO) SRC_REPO=$(SRC_REPO)


check_docker:
	@docker version >/dev/null 2>&1 || (echo "docker is not installed" && exit 1)

check_buildx:
	@docker buildx version >/dev/null 2>&1 || (echo "docker buildx is not installed" && exit 1)

init_buildx: check_buildx
	if [ -z "`docker buildx ls | grep multiarch_builder`" ]; then \
		docker buildx create --name multiarch_builder --use; \
		docker buildx inspect mybuilder --bootstrap; \
	fi
