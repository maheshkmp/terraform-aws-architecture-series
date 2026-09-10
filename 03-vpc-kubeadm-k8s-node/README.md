# 03 - Single-Node Kubeadm Kubernetes Cluster on AWS EC2

This Terraform module provisions a custom AWS VPC with a single-node **Kubernetes (`kubeadm`)** control plane server running on Ubuntu 24.04 LTS.

It automatically installs and configures:
- **Container Runtime:** `containerd` with `SystemdCgroup` enabled
- **Kubernetes Binaries:** `kubeadm`, `kubelet`, `kubectl` (v1.30)
- **Kernel Configurations:** `overlay`, `br_netfilter`, `ip_forward`
- **Storage & Networking:** 30GB `gp3` EBS volume, Elastic IP (EIP), and restricted Security Group.

---

## 🏛️ Architecture Overview

```
+-----------------------------------------------------------------------------------+
|                                     AWS Cloud                                     |
|                                                                                   |
|  +-----------------------------------------------------------------------------+  |
|  |                     VPC: traveny-k8s-vpc (10.0.0.0/16)                      |  |
|  |                                                                             |  |
|  |  +-----------------------------------------------------------------------+  |  |
|  |  |            Public Subnet: traveny-k8s-subnet (10.0.1.0/24)            |  |  |
|  |  |                                                                       |  |  |
|  |  |   +---------------------------------------------------------------+   |  |  |
|  |  |   |             Security Group: traveny-k8s-sg                    |   |  |  |
|  |  |   |                                                               |   |  |  |
|  |  |   |   +-------------------------------------------------------+   |   |  |  |
|  |  |   |   |   Elastic IP (Static) ===> EC2 Instance (t3.medium)   |   |   |  |  |
|  |  |   |   |   - OS: Ubuntu 24.04 LTS                             |   |   |  |  |
|  |  |   |   |   - Storage: 30GB gp3 EBS                             |   |   |  |  |
|  |  |   |   |   - Runtime: containerd                               |   |   |  |  |
|  |  |   |   |   - K8s: kubeadm + kubelet + kubectl                  |   |   |  |  |
|  |  |   |   +-------------------------------------------------------+   |   |  |  |
|  |  |   |        ▲ SSH (22)  ▲ HTTP (80)  ▲ HTTPS (443)  ▲ K8s API (6443) |   |  |  |
|  |  |   +--------|-----------|------------|-------------|---------------+   |  |  |
|  |  +------------|-----------|------------|-------------|-------------------+  |  |
|  |               |           |            |             |                      |  |
|  |               |           ▼            ▼             |                      |  |
|  |  +------------|--------------------------------------|-------------------+  |  |
|  |  | Route Table| traveny-public-rt                        |                   |  |  |
|  |  | Destination| 0.0.0.0/0 ---> Internet Gateway         |                   |  |  |
|  |  +------------|--------------------------------------|-------------------+  |  |
|  |               |                                      |                      |  |
|  |               ▼                                      ▼                      |  |
|  |  +-----------------------------------------------------------------------+  |  |
|  |  | Internet Gateway: traveny-k8s-igw                                     |  |  |
|  |  +-----------------------------------------------------------------------+  |  |
|  +-----------------------------------|-----------------------------------------+  |
+--------------------------------------|--------------------------------------------+
```

---

## 💻 Quick Start & Provisioning

### 1. Initialize Terraform
```bash
cd 03-vpc-kubeadm-k8s-node
terraform init
```

### 2. Configure your IP address
Get your public IP address:
```bash
curl -s https://checkip.amazonaws.com
```
Update `my_ip` in `dev.tfvars`:
```hcl
my_ip = "YOUR_PUBLIC_IP"
```

### 3. Review Plan & Apply
```bash
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```

---

## ☸️ Post-Provisioning: Initializing Kubernetes Cluster

Once Terraform completes and outputs your **Elastic IP**:

### Step 1: SSH into the Node
```bash
ssh ubuntu@<ELASTIC_IP>
```

### Step 2: Initialize Kubernetes Control Plane
Run `kubeadm init` specifying the Flannel pod network CIDR and your Elastic IP in extra SANs:

```bash
sudo kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --apiserver-cert-extra-sans=<ELASTIC_IP>
```

### Step 3: Configure `kubectl` for non-root user
```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### Step 4: Untaint Master Node (For Single-Node Workloads)
```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

### Step 5: Install Flannel CNI Network Plugin
```bash
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

### Step 6: Install Rancher Local-Path Storage Provisioner
```bash
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.30/deploy/local-path-storage.yaml
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

### Step 7: Verify Cluster Health
```bash
kubectl get nodes
kubectl get pods -A
```

---

## 🏷️ Variables Reference

| Variable | Type | Description |
| :--- | :--- | :--- |
| `region` | `string` | AWS Region (default: `us-east-1`) |
| `instance_type` | `string` | EC2 instance sizing (minimum `t3.medium` for 2 vCPU / 4GB RAM) |
| `environment` | `string` | Tag identifying stage (`dev` / `prod`) |
| `my_ip` | `string` | IP allowed SSH (22) and K8s API (6443) access |
| `ssh_public_key_path` | `string` | Path to public key file (default: `~/.ssh/id_rsa.pub`) |
