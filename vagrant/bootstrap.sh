#!/bin/bash

echo "Boostrapping k8s..."

export DEBIAN_FRONTEND=noninteractive

# Update hosts file
echo "[TASK 1] Update /etc/hosts file"
cat >>/etc/hosts<<EOF
172.27.0.100 kmaster
172.27.0.101 kworker1
172.27.0.102 kworker2
EOF

# Install docker
echo "[TASK 2] Install docker container engine"
apt-get update
apt-get remove -y docker docker-engine docker.io containerd runc
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
mkdir -p /etc/systemd/system/docker.service.d

# Enable docker service
echo "[TASK 3] Enable and start docker service"
systemctl daemon-reload
systemctl enable docker >/dev/null 2>&1
systemctl restart docker

# Disable AppArmor
echo "[TASK 4] Disable AppArmor"
systemctl stop apparmor
systemctl disable apparmor

# Stop and disable ufw
echo "[TASK 5] Stop and Disable ufw"
systemctl disable ufw >/dev/null 2>&1
systemctl stop ufw

# Disable swap
echo "[TASK 7] Disable and turn off SWAP"
sed -i '/swap/d' /etc/fstab
swapoff -a

# Install kubernetes
echo "[TASK 8] Install kubernetes"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
apt-get update
apt-get install -y kubeadm kubelet kubectl
apt-mark hold kubeadm kubelet kubectl

# Start and Enable kubelet service
echo "[TASK 9] Enable and start kubelet service"
systemctl enable kubelet >/dev/null 2>&1
systemctl start kubelet >/dev/null 2>&1