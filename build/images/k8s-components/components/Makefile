SRC_REPO=registry.aliyuncs.com/google_containers

DST_REPO=registry.cn-hangzhou.aliyuncs.com/bocloud

K8S_VERSION=1.27.1

images= kube-apiserver:v$(K8S_VERSION) kube-controller-manager:v$(K8S_VERSION) kube-scheduler:v$(K8S_VERSION) kube-proxy:v$(K8S_VERSION)

ALL_ARCH=linux/amd64,linux/arm64

all: release

amd64:
	@for image in $(images); do \
            echo "docker pull --platform linux/amd64 $(SRC_REPO)/$${image}"; \
    		docker pull --platform linux/amd64 $(SRC_REPO)/$${image}; \
    		echo "docker tag $(SRC_REPO)/$${image} $(DST_REPO)/$${image}"; \
    		docker tag $(SRC_REPO)/$${image} $(DST_REPO)/$${image} > /dev/null; \
    		echo "docker push $(DST_REPO)/$${image}"; \
    		docker push $(DST_REPO)/$${image}; \
    		echo "docker rmi $(DST_REPO)/$${image}"; \
    		docker rmi $(DST_REPO)/$${image} > /dev/null; \
    		echo "docker rmi $(SRC_REPO)/$${image}"; \
    		docker rmi $(SRC_REPO)/$${image} > /dev/null; \
    		echo "***** get $${image} success *****"; \
    	done

arm64:
	@for image in $(images); do \
			echo "docker pull --platform linux/arm64 $(SRC_REPO)/$${image}"; \
			docker pull --platform linux/arm64 $(SRC_REPO)/$${image}; \
			echo "docker tag $(SRC_REPO)/$${image} $(DST_REPO)/$${image}"; \
			docker tag $(SRC_REPO)/$${image} $(DST_REPO)/$${image} > /dev/null; \
			echo "docker push $(DST_REPO)/$${image}"; \
			docker push $(DST_REPO)/$${image}; \
			echo "docker rmi $(DST_REPO)/$${image}"; \
			docker rmi $(DST_REPO)/$${image} > /dev/null; \
			echo "docker rmi $(SRC_REPO)/$${image}"; \
			docker rmi $(SRC_REPO)/$${image} > /dev/null; \
			echo "***** get $${image} success *****"; \
		done

release:
	@for image in $(images); do \
		echo "FROM $(SRC_REPO)/$${image}" > Dockerfile; \
		docker buildx build \
			-t $(DST_REPO)$${image} \
			--platform $(ALL_ARCH) \
			. \
			--push; \
	done

build-amd64:
	@for image in $(images); do \
		docker pull --platform linux/amd64 $(SRC_REPO)/$${image}; \
		docker tag $(SRC_REPO)/$${image} $(DST_REPO)/$${image}-amd64; \
		docker push $(DST_REPO)/$${image}-amd64; \
		docker rmi $(DST_REPO)/$${image}-amd64; \
		docker rmi $(SRC_REPO)/$${image}; \
	done

build-arm64:
	@for image in $(images); do \
		docker pull --platform linux/arm64 $(SRC_REPO)/$${image}; \
		docker tag $(SRC_REPO)/$${image} $(DST_REPO)/$${image}-arm64; \
		docker push $(DST_REPO)/$${image}-arm64; \
		docker rmi $(DST_REPO)/$${image}-arm64; \
		docker rmi $(SRC_REPO)/$${image}; \
	done

manifest:
	@for image in $(images); do \
		docker manifest create --insecure $(DST_REPO)/$${image} $(DST_REPO)/$${image}-amd64 $(DST_REPO)/$${image}-arm64; \
		docker manifest annotate $(DST_REPO)/$${image} $(DST_REPO)/$${image}-amd64 --os linux --arch amd64; \
		docker manifest annotate $(DST_REPO)/$${image} $(DST_REPO)/$${image}-arm64 --os linux --arch arm64; \
		docker manifest push --insecure $(DST_REPO)/$${image}; \
	done