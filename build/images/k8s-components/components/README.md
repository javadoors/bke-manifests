# k8s组件镜像获取

k8s组件镜像双架构（arm64、amd64）镜像制作依赖docker buildx工具，buildx的安装不做介绍

k8s组件包含：kube-apiserver、kube-controller-manager、kube-scheduler、kube-proxy

1.  以获取1.27.1 k8s组件双架构（arm64 amd64）镜像为例
    ```bash
    make release K8S_VERSION=1.27.1
    ```
2.  获取任意版本k8s组件双架构（arm64、amd64）镜像

    注意K8S_VERSION没有带 "v"

    如需获取k8s组件1.21.1则替换下方X.XX.X为1.21.1
    ```bash
    make release K8S_VERSION=X.XX.X
    ```
3.  指定镜像上传的仓库

    docker buildx 上传镜像到镜像仓库需要使用带证书的安全仓库，如无认证无证书的私有镜像仓库不支持
    ```bash
    make release K8S_VERSION=1.27.1 DST_REPO=registry.cn-hangzhou.aliyuncs.com/bocloud
    ```
4.  指定镜像的下载仓库

    k8s组件镜像默认从[registry.aliyuncs.com/google\_containers/](http://registry.aliyuncs.com/google_containers/ "registry.aliyuncs.com/google_containers/")仓库下载
    ```bash
    make release K8S_VERSION=1.27.1 DST_REPO=registry.cn-hangzhou.aliyuncs.com/bocloud SRC_REPO=registry.aliyuncs.com/google_containers
    ```
5.  不使用buildx打包

    不使用buildx打包镜像时，如需获取arm64的镜像需在arm64架构的主机上进行操作
    ```bash
    make build-arm64 K8S_VERSION=X.XX.X DST_REPO=registry.cn-hangzhou.aliyuncs.com/bocloud

    make build-amd64 K8S_VERSION=X.XX.X DST_REPO=registry.cn-hangzhou.aliyuncs.com/bocloud
    ```
6.  在进行完步骤5操作后，可创建多架构镜像
    ```bash
    make manifest K8S_VERSION=X.XX.X DST_REPO=registry.cn-hangzhou.aliyuncs.com/bocloud
    ```