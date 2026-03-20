# kubelet镜像制作

- 部分rpm仓库失效

**kubelet双架构（arm64、amd64）镜像制作依赖docker buildx工具，buildx的安装不做介绍**

1.**以制作1.27.1的kubelet双架构（arm64、amd64）镜像为例**

    ```
    make release KUBELET_VERSION=1.27.1
    ```

2.**制作任意版本kubelet双架构（arm64、amd64）镜像**

注意KUBELET_VERSION没有带 "v"

如需制作kubelet 1.21.1则替换下方X.XX.X为1.21.1

    ```
    make release KUBELET_VERSION=X.XX.X
    ```

3.**指定镜像上传的仓库**

docker buildx 上传镜像到镜像仓库需要使用带证书的安全仓库，如无认证无证书的私有镜像仓库不支持

    ```
    make release KUBELET_VERSION=X.XX.X REPO=registry.cn-hangzhou.aliyuncs.com/bocloud
    ```

4.**不使用buildx打包**

不使用buildx打包镜像时，如需打包arm64的kubelet需在arm64的主机上进行操作

    ```
    make build-arm64 KUBELET_VERSION=X.XX.X REPO=registry.cn-hangzhou.aliyuncs.com/bocloud
    
    make build-amd64 KUBELET_VERSION=X.XX.X REPO=registry.cn-hangzhou.aliyuncs.com/bocloud
    ```

5.**在进行完步骤4操作后，可创建多架构镜像**

    ```
    make manifest KUBELET_VERSION=X.XX.X REPO=registry.cn-hangzhou.aliyuncs.com/bocloud
    ```
