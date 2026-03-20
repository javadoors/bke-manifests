# 使用文档

参数解释

| 参数           | 必填 | 解释              | 默认值                                                                                                                                  |
| ------------ | -- | --------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| K8S\_VERSION | 否  | 指定k8s版本         | 1.27.1                                                                                                                               |
| SRC\_REPO    | 否  | 指定k8s组件镜像下载的源仓库 | [registry.aliyuncs.com/google\_containers](http://registry.aliyuncs.com/google_containers "registry.aliyuncs.com/google_containers") |
| DST\_REPO    | 否  | 指定k8s组件镜像推送的仓库  | [deploy.bocloud.com:40443/kubernetes](http://deploy.bocloud.com:40443/kubernetes "deploy.bocloud.com:40443/kubernetes")              |

***注意使用脚本前确保即将使用的DST\_REPO和SRC\_REPO在两台机器上都能访问***

### 使用docker buildx直接获取k8s组件双架镜像

准备任意架构机器一台确保已安装docker和make以及docker buildx

```bash
make release K8S_VERSION=1.27.1 SRC_REPO=registry.aliyuncs.com/google_containers DST_REPO=deploy.bocloud.com:40443/kubernetes
```

### 不使用docker buildx 获取双架镜像

准备amd64机器和arm64机器各一台确保已安装docker和make

```bash
#1.拷贝脚本到amd64机器上并执行以下命令
make build-amd64 K8S_VERSION=1.27.1 SRC_REPO=registry.aliyuncs.com/google_containers DST_REPO=deploy.bocloud.com:40443/kubernetes
#2.拷贝脚本到arm64机器上并执行以下命令
make build-arm64 K8S_VERSION=1.27.1 SRC_REPO=registry.aliyuncs.com/google_containers DST_REPO=deploy.bocloud.com:40443/kubernetes
#3.在上面机器中的任意一台中执行以下命令
make manifest K8S_VERSION=1.27.1 SRC_REPO=registry.aliyuncs.com/google_containers DST_REPO=deploy.bocloud.com:40443/kubernetes
```

### 只获取amd64架构镜像

准备amd64机器一台确保已安装docker和make

```bash
make amd64 K8S_VERSION=1.27.1 SRC_REPO=registry.aliyuncs.com/google_containers DST_REPO=deploy.bocloud.com:40443/kubernetes
```

### 只获取arm64架构镜像

准备amd64机器一台确保已安装docker和make

```bash
make arm64 K8S_VERSION=1.27.1 SRC_REPO=registry.aliyuncs.com/google_containers DST_REPO=deploy.bocloud.com:40443/kubernetes
```