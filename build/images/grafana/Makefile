DST_REPO=192.168.2.140:5001/kubernetes/
NAME=grafana
VERSION=8.3.3
ARCH ?= linux/arm64,linux/amd64

BASE_IMAGE=deploy.bocloud.k8s:40443/kubernetes/grafana:8.3.3

DST_IMAGE=$(DST_REPO)$(NAME):$(VERSION)

release:
	@docker buildx build \
		--push \
		--progress plain \
		--platform=$(ARCH) \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		-t $(DST_IMAGE) .


migrate:
	@bke registry sync --dest-tls-verify --source $(BASE_IMAGE) --target $(DST_IMAGE) --multi-arch