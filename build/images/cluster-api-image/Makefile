
SRC_REPO=gcr.lank8s.cn/k8s-staging-cluster-api/

DST_REPO=registry.cn-hangzhou.aliyuncs.com/bocloud/

#VERSION=v1.3.2
VERSION=v1.4.3

CLUSTER_API_CONTROLLER=cluster-api-controller
CLUSTER_API_CONTROLLER_IMAGE=$(DST_REPO)$(CLUSTER_API_CONTROLLER):$(VERSION)

KUBEADM_BOOTSTRAP_CONTROLLER=kubeadm-bootstrap-controller
KUBEADM_BOOTSTRAP_CONTROLLER_IMAGE=$(DST_REPO)$(KUBEADM_BOOTSTRAP_CONTROLLER):$(VERSION)

KUBEADM_CONTROL_PLANE_CONTROLLER=kubeadm-control-plane-controller
KUBEADM_CONTROL_PLANE_CONTROLLER_IMAGE=$(DST_REPO)$(KUBEADM_CONTROL_PLANE_CONTROLLER):$(VERSION)


ALL_ARCH=linux/amd64,linux/arm64


all: cluster-api-controller kubeadm-bootstrap-controller kubeadm-control-plane-controller

.PHONY: cluster-api-controller
cluster-api-controller:
	echo "FROM $(SRC_REPO)$(CLUSTER_API_CONTROLLER):$(VERSION)" > ./cluster-api-controller/Dockerfile
	@docker buildx build \
		-t $(CLUSTER_API_CONTROLLER_IMAGE) \
		--platform $(ALL_ARCH) \
		--progress plain \
		-f ./cluster-api-controller/Dockerfile \
		. \
		--push

.PHONY: kubeadm-bootstrap-controller
kubeadm-bootstrap-controller:
	echo "FROM $(SRC_REPO)$(KUBEADM_BOOTSTRAP_CONTROLLER):$(VERSION)" > ./kubeadm-bootstrap-controller/Dockerfile
	@docker buildx build \
		-t $(KUBEADM_BOOTSTRAP_CONTROLLER_IMAGE) \
		--platform $(ALL_ARCH) \
		--progress plain \
		-f ./kubeadm-bootstrap-controller/Dockerfile \
		. \
		--push

.PHONY: kubeadm-control-plane-controller
kubeadm-control-plane-controller:
	echo "FROM $(SRC_REPO)$(KUBEADM_CONTROL_PLANE_CONTROLLER):$(VERSION)" > ./kubeadm-control-plane-controller/Dockerfile
	@docker buildx build \
		-t $(KUBEADM_CONTROL_PLANE_CONTROLLER_IMAGE) \
		--platform $(ALL_ARCH) \
		--progress plain \
		-f ./kubeadm-control-plane-controller/Dockerfile \
		. \
		--push
