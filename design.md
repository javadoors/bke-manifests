我来探索bke-manifests项目的代码实现，然后生成详细设计文档。
     
基于对bke-manifests项目的深入分析，我为您生成详细设计文档：

# bke-manifests 详细设计说明书

## 1. 概述

### 1.1 项目简介
bke-manifests是BKE（Bocloud Enterprise Kubernetes）的组件清单仓库，存储各个产品组件的部署YAML文件。采用Go Template方式进行参数替换，支持多版本管理和灵活配置。

### 1.2 核心功能
- **组件清单管理**：存储Kubernetes组件的部署YAML
- **版本管理**：支持组件多版本共存
- **模板渲染**：使用Go Template进行参数替换
- **镜像打包**：构建包含所有manifests的容器镜像
- **初始化脚本**：提供节点初始化脚本库

### 1.3 设计理念
- **声明式配置**：所有组件采用Kubernetes声明式配置
- **参数化部署**：通过模板变量实现配置复用
- **版本隔离**：不同版本组件独立存储
- **Sidecar模式**：以sidecar方式附加到cluster-api-provider-bke

## 2. 架构设计

### 2.1 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                    bke-manifests 镜像                        │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                  /workspace                            │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌──────────────┐  │  │
│  │  │ kubernetes/ │  │bkeinitscript│  │  BUILD_INFO  │  │  │
│  │  │             │  │     /       │  │              │  │  │
│  │  │ - coredns/  │  │ - *.sh      │  │ - Version    │  │  │
│  │  │ - calico/   │  │ - *.py      │  │ - GitCommit  │  │  │
│  │  │ - prometheus│  │             │  │ - Arch       │  │  │
│  │  │ - ...       │  │             │  │ - BuildTime  │  │  │
│  │  └─────────────┘  └─────────────┘  └──────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              cluster-api-provider-bke (Sidecar)              │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              Manifests Renderer                        │  │
│  │  1. 读取manifests文件                                   │  │
│  │  2. 解析Go Template                                     │  │
│  │  3. 替换参数变量                                        │  │
│  │  4. 应用到Kubernetes集群                                │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 目录结构

```
bke-manifests/
├── kubernetes/                    # Kubernetes组件清单
│   ├── coredns/                  # CoreDNS组件
│   │   ├── v1.8.0/
│   │   ├── v1.8.6/
│   │   ├── v1.9.3/
│   │   ├── v1.10.1/
│   │   └── v1.12.2-of.1/
│   │       └── coredns.yaml
│   ├── calico/                   # Calico网络插件
│   │   ├── v3.25.0/
│   │   ├── v3.27.3/
│   │   └── v3.31.3/
│   │       └── calico.yaml
│   ├── kubeproxy/               # Kube-Proxy
│   │   ├── v1.21.14/
│   │   ├── v1.25.6/
│   │   ├── v1.33.1/
│   │   └── v1.34.3-of.1/
│   ├── cluster-api/             # Cluster API
│   │   ├── v1.1.4/
│   │   ├── v1.3.2/
│   │   └── v1.4.3/
│   │       ├── 001-webhook-secrets.yaml
│   │       ├── 002-cluster-api.yaml
│   │       ├── 003-cluster-api-bke.yaml
│   │       └── 004-manage.yaml
│   ├── prometheus/              # Prometheus监控
│   │   ├── v2.11.0/
│   │   └── v2.32.1/
│   ├── cert-manager/            # 证书管理
│   │   └── v1.11.0/
│   ├── bkeagent/                # BKE Agent
│   │   └── latest/
│   ├── bkeagent-deployer/       # Agent部署器
│   ├── clusterextra/            # 集群扩展脚本
│   │   ├── install-helm.sh/
│   │   │   └── agent-command.yaml
│   │   ├── install-calicoctl.sh/
│   │   └── latest/
│   │       └── extra.yaml
│   ├── gpu-manager/             # GPU管理
│   ├── kube-gpu/                # GPU调度
│   ├── katib/                   # 超参数调优
│   ├── kserve/                  # 模型服务
│   ├── volcano/                 # 批处理调度
│   ├── jenkins/                 # CI/CD
│   ├── argo-workflow/           # 工作流
│   ├── mysql/                   # MySQL数据库
│   ├── postgres/                # PostgreSQL数据库
│   ├── redis/                   # Redis缓存
│   ├── minio/                   # 对象存储
│   ├── nfs-csi/                 # NFS CSI驱动
│   └── ...                      # 其他组件
├── bkeinitscript/               # 初始化脚本
│   ├── install-helm.sh
│   ├── install-calicoctl.sh
│   ├── install-etcdctl.sh
│   ├── install-nfsutils.sh
│   ├── kernel.sh
│   ├── nfs-mount.sh
│   ├── file-downloader.sh
│   └── clean_docker_images.py
├── build/                       # 构建配置
│   ├── images/                  # 组件镜像构建
│   │   ├── calico-image/
│   │   ├── cert-manager/
│   │   ├── cluster-api-image/
│   │   ├── grafana/
│   │   └── k8s-components/
│   ├── light/                   # 精简构建配置
│   │   ├── v121-light-build-amd64.yaml
│   │   └── v125-light-build-amd64.yaml
│   └── scripts/
│       └── find-boc-image-time.sh
├── rpms/                        # RPM包构建
│   ├── centos7-Dockerfile
│   ├── centos8-Dockerfile
│   ├── openeuler2203-Dockerfile
│   └── ubuntu22-Dockerfile
├── scripts/                     # 构建脚本
│   ├── buildx.sh
│   └── package.sh
├── main.go                      # 入口程序
├── Dockerfile                   # 镜像构建文件
├── Makefile                     # 构建规则
└── README.md                    # 项目说明
```

## 3. 核心设计

### 3.1 模板系统设计

#### 3.1.1 模板语法

bke-manifests使用Go Template语法进行参数替换：

**变量替换**：
```yaml
image: {{.repo}}coredns:v1.10.1
```

**条件渲染**：
```yaml
{{- if eq .allowTypha "true" }}
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: calico-typha
{{- end}}
```

**循环渲染**：
```yaml
{{- $ips := split .nodesIps "," }}
{{- range $ips }}
  {{ . }}: {{ . }}
{{- end }}
```

**默认值**：
```yaml
replicas: {{ .replicas | default 2 }}
```

#### 3.1.2 模板变量

| 变量名 | 说明 | 示例值 |
|--------|------|--------|
| `{{.repo}}` | 镜像仓库地址 | `deploy.bocloud.k8s:40443/kubernetes/` |
| `{{.dnsDomain}}` | 集群DNS域名 | `cluster.local` |
| `{{.dnsIP}}` | DNS服务IP | `10.96.0.10` |
| `{{.allowTypha}}` | 是否启用Typha | `true`/`false` |
| `{{.EnableAntiAffinity}}` | 是否启用反亲和性 | `true`/`false` |
| `{{.namespace}}` | 命名空间 | `kube-system` |
| `{{.nodesIps}}` | 节点IP列表 | `192.168.1.1,192.168.1.2` |
| `{{.httpRepo}}` | HTTP仓库地址 | `http://deploy.bocloud.k8s:40080` |

### 3.2 组件分类设计

#### 3.2.1 核心组件

| 组件 | 版本范围 | 说明 |
|------|---------|------|
| CoreDNS | v1.8.0 ~ v1.12.2-of.1 | 集群DNS服务 |
| Calico | v3.25.0 ~ v3.31.3 | 网络插件 |
| Kube-Proxy | v1.21.14 ~ v1.34.3-of.1 | 服务代理 |
| Cluster API | v1.1.4 ~ v1.4.3 | 集群生命周期管理 |
| Cert Manager | v1.11.0 | 证书管理 |

#### 3.2.2 监控组件

| 组件 | 版本 | 说明 |
|------|------|------|
| Prometheus | v2.11.0, v2.32.1 | 监控系统 |
| Grafana | - | 可视化面板 |
| VictoriaMetrics | 0.20.0, latest | 时序数据库 |
| Node Exporter | - | 节点指标采集 |
| Kube State Metrics | - | Kubernetes指标 |

#### 3.2.3 存储组件

| 组件 | 版本 | 说明 |
|------|------|------|
| NFS CSI | v4.1.0 | NFS存储驱动 |
| MinIO | 2023-04-20 | 对象存储 |
| MySQL | 5.7, 8.0.29 | 关系数据库 |
| PostgreSQL | 16 | 关系数据库 |
| Redis | 6.2.12 | 缓存数据库 |

#### 3.2.4 AI/ML组件

| 组件 | 版本 | 说明 |
|------|------|------|
| Katib | v0.15.0 | 超参数调优 |
| KServe | v0.11.2 | 模型服务 |
| Volcano | release-1.7-bcc | 批处理调度 |
| VPA | 0.10.0 | 垂直自动扩缩容 |

#### 3.2.5 工具组件

| 组件 | 版本 | 说明 |
|------|------|------|
| Jenkins | 2.278, 2.375.3-lts | CI/CD |
| Argo Workflow | v3.4.3 | 工作流引擎 |
| Helm Controller | 1.6.12, 1.6.13 | Helm管理 |
| KubeVirt | v1.0.0 | 虚拟化管理 |

### 3.3 版本管理设计

#### 3.3.1 版本命名规范

```
<组件名>/<版本号>/<文件名>.yaml

版本号格式：
- 标准版本：v1.10.1
- 定制版本：v1.12.2-of.1 (of表示openFuyao定制)
- 开发版本：latest, dev-xxx
```

#### 3.3.2 多文件组件

对于复杂组件，采用数字前缀排序：

```
cluster-api/v1.4.3/
├── 001-webhook-secrets.yaml      # 第一步：证书
├── 002-cluster-api.yaml          # 第二步：Cluster API核心
├── 003-cluster-api-bke.yaml      # 第三步：BKE Provider
└── 004-manage.yaml               # 第四步：管理组件
```

### 3.4 初始化脚本设计

#### 3.4.1 脚本规范

```bash
#!/bin/bash

# 日志文件
log_file="/var/log/openFuyao/bkeagent.log"
[ -f "$log_file" ] || touch "$log_file"

# 日志函数
log() {
  local msg=$1
  echo "$(date +'%Y-%m-%d %H:%M:%S')     INFO    install-helm.sh     $msg" >> "$log_file"
  echo "$(date +'%Y-%m-%d %H:%M:%S')     INFO    install-helm.sh     $msg"
}

# 系统检测
if [ -f /etc/os-release ]; then
    source /etc/os-release
    os_type=$ID
    os_version=$VERSION_ID
else
    log "不支持的操作系统"
    exit 1
fi

# 架构转换
arch=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/;s/^unknown$/amd64/')

# 主逻辑
...
```

#### 3.4.2 脚本分类

| 脚本 | 功能 | 使用场景 |
|------|------|---------|
| install-helm.sh | 安装Helm客户端 | 节点初始化 |
| install-calicoctl.sh | 安装Calico命令行工具 | 网络管理 |
| install-etcdctl.sh | 安装etcd命令行工具 | etcd管理 |
| install-nfsutils.sh | 安装NFS工具 | 存储挂载 |
| kernel.sh | 内核参数配置 | 系统优化 |
| nfs-mount.sh | NFS挂载 | 存储配置 |
| file-downloader.sh | 文件下载 | 资源获取 |
| clean_docker_images.py | 清理Docker镜像 | 磁盘清理 |

### 3.5 Agent Command设计

#### 3.5.1 Command CRD结构

```yaml
apiVersion: bkeagent.bocloud.com/v1beta1
kind: Command
metadata:
  name: install-helm
  namespace: {{.namespace}}
spec:
  suspend: false
  commands:
    - backoffDelay: 3
      command:
        - "configmap:cluster-system/install-helm.sh:ro:{{$scriptDir}}install-helm.sh"
      id: save-install-helm-script
      type: Kubernetes
    - backoffDelay: 3
      command:
        - "chmod +x {{$scriptDir}}install-helm.sh"
      id: chmod-install-helm
      type: Shell
    - backoffDelay: 10
      command:
        - "{{$scriptDir}}install-helm.sh {{.httpRepo}}"
      id: install-helm
      type: Shell
  backoffLimit: 3
  nodeSelector:
    matchLabels:
    {{- $ips := split .nodesIps "," }}
    {{- range $ips }}
      {{ . }}: {{ . }}
    {{- end }}
```

#### 3.5.2 命令类型

| 类型 | 说明 | 示例 |
|------|------|------|
| Kubernetes | Kubernetes资源操作 | 创建ConfigMap、Secret |
| Shell | Shell命令执行 | chmod、脚本执行 |
| Docker | Docker操作 | 镜像拉取、容器管理 |

## 4. 构建系统设计

### 4.1 Dockerfile设计

```dockerfile
# syntax=docker/dockerfile:latest

# 构建阶段
ARG BUILDER_IMAGE=debian:trixie-slim
FROM $BUILDER_IMAGE AS build
ARG COMMIT
ARG VERSION
ARG TARGETARCH
ARG SOURCE_DATE_EPOCH

RUN <<'EOF'
#!/bin/sh -xe
cat <<EOT > BUILD_INFO
🤯 Version=$VERSION
🤔 GitCommitId=$COMMIT
👉 Architecture=$TARGETARCH
⏲ BuildTime=$(date -u +'%FT%T.%3NZ' -d@$SOURCE_DATE_EPOCH)
EOT
EOF

# 发布阶段
ARG BASE_IMAGE=alpine:3.20.3
FROM $BASE_IMAGE AS release
WORKDIR /workspace

# 复制构建信息
COPY --link --from=build --chmod=444 /BUILD_INFO ./

# 复制manifests文件
COPY --link --chmod=444 kubernetes ./kubernetes

# 复制初始化脚本
COPY --link --chmod=555 bkeinitscript ./bkeinitscript

ENTRYPOINT ["/bin/cat"]
```

### 4.2 Makefile设计

```makefile
# 仓库配置
REPOSITORY ?= deploy.bocloud.k8s:40443/kubernetes
REPOSITORY2=registry.cn-hangzhou.aliyuncs.com/bocloud

# 镜像配置
NAME ?= addons
VERSION ?= latest
ARCH ?= linux/arm64,linux/amd64

# 镜像地址
REPOSITORY_IMAGE ?= $(REPOSITORY)/$(NAME):$(VERSION)
REPOSITORY2_IMAGE ?= $(REPOSITORY2)/$(NAME):$(VERSION)

# Git信息
COMMIT_ID=$(shell git rev-parse HEAD)
BUILD_TIME=$(shell date +'%Y-%m-%dT%H:%M')
HOST_ARCH=$(shell go env GOHOSTARCH)

# 本地构建
.PHONY: docker-build
docker-build: record-build-info
	docker build \
		--no-cache \
		--network host \
		--platform=linux/${HOST_ARCH} \
		--build-arg COMMIT_ID=${COMMIT_ID} \
		--build-arg BUILD_TIME=${BUILD_TIME} \
		--build-arg TARGETARCH=${HOST_ARCH} \
		--build-arg VERSION=${VERSION} \
		-t ${REPOSITORY}/addons:${VERSION}-${HOST_ARCH} .

# 多架构发布
.PHONY: release-image
release-image: record-build-info
	@docker buildx build \
		--build-arg COMMIT_ID=${COMMIT_ID} \
		--build-arg BUILD_TIME=${BUILD_TIME} \
		-t $(REPOSITORY2_IMAGE) \
		--platform=$(ARCH) \
		. --push
	@bke registry sync \
		--dest-tls-verify \
		--source $(REPOSITORY2_IMAGE) \
		--target $(REPOSITORY_IMAGE) \
		--multi-arch

# 记录构建信息
.PHONY: record-build-info
record-build-info:
	> BUILD_INFO
	echo "🤯 Version=${VERSION}" >> BUILD_INFO
	echo "🤔 GitCommitId=${COMMIT_ID}" >> BUILD_INFO
	echo "👉 Architecture=${HOST_ARCH}" >> BUILD_INFO
	echo "⏲ BuildTime=${BUILD_TIME}" >> BUILD_INFO
```

### 4.3 精简构建配置

```yaml
# v125-light-build-amd64.yaml
registry:
  imageAddress: deploy.bocloud.k8s:40443/kubernetes/registry:2.8.1
  architecture:
    - amd64

repos:
  - architecture:
      - amd64
    sourceRepo: deploy.bocloud.k8s:40443/kubernetes
    targetRepo: kubernetes
    images:
      # 基础组件
      - name: k3s
        tag: [v1.25.16-k3s4]
      - name: coredns
        tag: [v1.10.1]
      - name: pause
        tag: [3.8]
      
      # BKE组件
      - name: addons
        tag: [latest]
      - name: bkeagent-launcher
        tag: [latest]
      
      # Cluster API
      - name: cluster-api-controller
        tag: [v1.4.3]
      - name: kubeadm-bootstrap-controller
        tag: [v1.4.3]
      - name: kubeadm-control-plane-controller
        tag: [v1.4.3]
      
      # Kubernetes组件
      - name: kube-apiserver
        tag: [v1.25.6]
      - name: kube-controller-manager
        tag: [v1.25.6]
      - name: kube-scheduler
        tag: [v1.25.6]
      - name: kubelet
        tag: [v1.25.6]

files:
  - address: http://deploy.bocloud.k8s:40080/files/
    files:
      - name: cni-plugins-linux-amd64-v1.2.0.tgz
      - name: kubeadm-v1.25.6
```

## 5. 组件详细设计

### 5.1 CoreDNS设计

```yaml
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: coredns
  namespace: kube-system

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health {
           lameduck 5s
        }
        ready
        kubernetes {{ .dnsDomain }} in-addr.arpa ip6.arpa {
           pods insecure
           fallthrough in-addr.arpa ip6.arpa
           ttl 30
        }
        prometheus :9153
        forward . /etc/resolv.conf
        cache 30
        loop
        reload
        loadbalance
    }

---
apiVersion: v1
kind: Service
metadata:
  name: kube-dns
  namespace: kube-system
spec:
  clusterIP: {{ .dnsIP }}
  ports:
    - name: dns
      port: 53
      protocol: UDP
    - name: dns-tcp
      port: 53
      protocol: TCP
  selector:
    k8s-app: kube-dns

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: coredns
  namespace: kube-system
spec:
  replicas: 2
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
  selector:
    matchLabels:
      k8s-app: kube-dns
  template:
    spec:
      priorityClassName: system-cluster-critical
      serviceAccountName: coredns
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                labelSelector:
                  matchExpressions:
                    - key: k8s-app
                      operator: In
                      values:
                        - kube-dns
                topologyKey: kubernetes.io/hostname
          {{- if eq .EnableAntiAffinity "true" }}
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                  - key: k8s-app
                    operator: In
                    values:
                      - kube-dns
              topologyKey: kubernetes.io/hostname
          {{- end }}
      containers:
        - name: coredns
          image: {{.repo}}coredns:v1.10.1
          resources:
            limits:
              memory: 170Mi
            requests:
              cpu: 100m
              memory: 70Mi
```

### 5.2 Calico设计

```yaml
---
# PodDisruptionBudget for Controllers
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: calico-kube-controllers
  namespace: kube-system
spec:
  maxUnavailable: 1
  selector:
    matchLabels:
      k8s-app: calico-kube-controllers

---
{{- if eq .allowTypha "true" }}
# PodDisruptionBudget for Typha
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: calico-typha
  namespace: kube-system
spec:
  maxUnavailable: 1
  selector:
    matchLabels:
      k8s-app: calico-typha
---
{{- end}}

---
# ConfigMap
kind: ConfigMap
apiVersion: v1
metadata:
  name: calico-config
  namespace: kube-system
data:
{{- if eq .allowTypha "true" }}
  typha_service_name: "calico-typha"
{{- else}}
  typha_service_name: "none"
{{- end}}
  calico_backend: "bird"
  veth_mtu: "0"
  cni_network_config: |-
    {
      "name": "k8s-pod-network",
      "cniVersion": "0.3.1",
      "plugins": [
        {
          "type": "calico",
          "datastore_type": "kubernetes",
          "nodename": "__KUBERNETES_NODE_NAME__",
          "mtu": __CNI_MTU__,
          "ipam": {"type": "calico-ipam"},
          "policy": {"type": "k8s"},
          "kubernetes": {"kubeconfig": "__KUBECONFIG_FILEPATH__"}
        },
        {
          "type": "portmap",
          "snat": true,
          "capabilities": {"portMappings": true}
        }
      ]
    }

---
# DaemonSet
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: calico-node
  namespace: kube-system
spec:
  selector:
    matchLabels:
      k8s-app: calico-node
  template:
    spec:
      serviceAccountName: calico-node
      containers:
        - name: calico-node
          image: {{.repo}}calico/node:v3.31.3
          env:
            - name: DATASTORE_TYPE
              value: "kubernetes"
            - name: FELIX_LOGSEVERITYSCREEN
              value: "info"
            - name: CLUSTER_TYPE
              value: "k8s,bgp"
            - name: IP
              value: "autodetect"
            - name: CALICO_IPV4POOL_IPIP
              value: "Always"
            - name: CALICO_NETWORKING_BACKEND
              value: "bird"
```

### 5.3 Cluster API设计

```yaml
---
# Namespace
apiVersion: v1
kind: Namespace
metadata:
  labels:
    cluster.x-k8s.io/provider: infrastructure-bke
    control-plane: controller-manager
  name: cluster-system

---
# CRD: ClusterClass
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    cert-manager.io/inject-ca-from: cluster-system/capi-serving-cert
  labels:
    cluster.x-k8s.io/provider: cluster-api
  name: clusterclasses.cluster.x-k8s.io
spec:
  conversion:
    strategy: Webhook
    webhook:
      clientConfig:
        service:
          name: capi-webhook-service
          namespace: cluster-system
          path: /convert
  group: cluster.x-k8s.io
  names:
    kind: ClusterClass
    plural: clusterclasses
  scope: Namespaced
  versions:
    - name: v1beta1
      served: true
      storage: true

---
# Deployment: Cluster API Controller
apiVersion: apps/v1
kind: Deployment
metadata:
  name: capi-controller-manager
  namespace: cluster-system
spec:
  replicas: 1
  selector:
    matchLabels:
      cluster.x-k8s.io/provider: cluster-api
  template:
    spec:
      containers:
        - name: manager
          image: {{.repo}}cluster-api-controller:v1.4.3
          args:
            --leader-elect
          resources:
            requests:
              cpu: 200m
              memory: 200Mi
```

## 6. 使用流程

### 6.1 镜像构建流程

```
开始
  │
  ├─→ 记录构建信息
  │     ├─ Version
  │     ├─ GitCommitId
  │     ├─ Architecture
  │     └─ BuildTime
  │
  ├─→ Docker多阶段构建
  │     ├─ 构建阶段：生成BUILD_INFO
  │     └─ 发布阶段：复制manifests和脚本
  │
  ├─→ 推送镜像到外部仓库
  │     └─ registry.cn-hangzhou.aliyuncs.com/bocloud/addons:latest
  │
  ├─→ 同步到内部仓库
  │     └─ deploy.bocloud.k8s:40443/kubernetes/addons:latest
  │
  └─→ 完成
```

### 6.2 组件部署流程

```
cluster-api-provider-bke
  │
  ├─→ 读取manifests文件
  │     └─ /workspace/kubernetes/<component>/<version>/<file>.yaml
  │
  ├─→ 解析Go Template
  │     ├─ 替换{{.repo}}
  │     ├─ 替换{{.dnsDomain}}
  │     └─ 条件渲染
  │
  ├─→ 应用到Kubernetes
  │     ├─ 创建Namespace
  │     ├─ 创建CRD
  │     ├─ 创建RBAC
  │     └─ 创建Deployment
  │
  └─→ 等待组件就绪
```

### 6.3 初始化脚本执行流程

```
BKE Agent
  │
  ├─→ 接收Command CRD
  │     └─ clusterextra/install-helm.sh/agent-command.yaml
  │
  ├─→ 解析命令序列
  │     ├─ save-install-helm-script (Kubernetes)
  │     ├─ chmod-install-helm (Shell)
  │     └─ install-helm (Shell)
  │
  ├─→ 选择目标节点
  │     └─ 根据nodeSelector匹配
  │
  ├─→ 顺序执行命令
  │     ├─ 从ConfigMap保存脚本
  │     ├─ 添加执行权限
  │     └─ 执行脚本
  │
  └─→ 上报执行结果
```

## 7. 配置管理

### 7.1 模板变量配置

```yaml
# 模板变量示例
repo: "deploy.bocloud.k8s:40443/kubernetes/"
dnsDomain: "cluster.local"
dnsIP: "10.96.0.10"
allowTypha: "true"
EnableAntiAffinity: "true"
namespace: "kube-system"
nodesIps: "192.168.1.1,192.168.1.2,192.168.1.3"
httpRepo: "http://deploy.bocloud.k8s:40080"
```

### 7.2 组件版本映射

```yaml
# Kubernetes版本与组件版本映射
kubernetes:
  v1.25.6:
    coredns: v1.10.1
    calico: v3.25.0
    kubeproxy: v1.25.6
    etcd: 3.5.6-0
    pause: 3.8
  
  v1.33.1:
    coredns: v1.12.2-of.1
    calico: v3.31.3
    kubeproxy: v1.33.1
    etcd: v3.6.7-of.1
    pause: 3.9
```

## 8. 最佳实践

### 8.1 Manifests编写规范

1. **文件命名**：使用小写字母和连字符
2. **资源顺序**：Namespace → RBAC → ConfigMap → Deployment
3. **镜像地址**：统一使用`{{.repo}}image:tag`格式
4. **资源限制**：为所有容器设置requests和limits
5. **健康检查**：配置livenessProbe和readinessProbe

### 8.2 版本管理规范

1. **语义化版本**：遵循SemVer规范
2. **定制标识**：使用`-of.x`后缀标识定制版本
3. **向后兼容**：新版本保持API兼容性
4. **废弃策略**：提前声明废弃计划

### 8.3 脚本编写规范

1. **错误处理**：检查命令执行结果
2. **日志记录**：统一日志格式和路径
3. **幂等性**：支持重复执行
4. **系统兼容**：支持多操作系统和架构

## 9. 总结

bke-manifests作为BKE的组件清单仓库，具有以下特点：

1. **声明式管理**：所有组件采用Kubernetes声明式配置
2. **模板化部署**：通过Go Template实现参数化配置
3. **版本隔离**：支持组件多版本共存和灵活选择
4. **Sidecar集成**：与cluster-api-provider-bke无缝集成
5. **可扩展性**：易于添加新组件和新版本

通过规范化的目录结构、模板系统和构建流程，bke-manifests为BKE提供了可靠的组件管理基础设施。
        
