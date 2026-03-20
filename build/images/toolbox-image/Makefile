DST_REPO=deploy.bocloud.k8s:40443/kubernetes/
PUBLIC_REPO=registry.cn-hangzhou.aliyuncs.com/bocloud
NAME=toolbox
VERSION=latest
ARCH ?= linux/arm64,linux/amd64

BASE_IMAGE=alpine:latest

DST_IMAGE=$(DST_REPO)$(NAME):$(VERSION)
PUBLIC_IMAGE=$(PUBLIC_REPO)$(NAME):$(VERSION)

release:
	@docker buildx build \
		--push \
		--progress plain \
		--platform=$(ARCH) \
		-t $(DST_IMAGE) .


migrate:
	@bke registry sync --dest-tls-verify --source $(DST_IMAGE) --target $(PUBLIC_IMAGE) --multi-arch