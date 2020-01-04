#!/bin/bash

echo "Bootstrapping k8s master..."

# Initialize Kubernetes
echo "[TASK 1] Initialize Kubernetes Cluster"
kubeadm init --apiserver-advertise-address=172.27.0.100 --pod-network-cidr=192.168.0.0/16 2>&1 | tee /home/vagrant/kubeinit.log

# Copy Kube admin config
echo "[TASK 2] Copy kube admin config to Vagrant user .kube directory"
mkdir /home/vagrant/.kube
cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown -R vagrant:vagrant /home/vagrant/.kube

export KUBECONFIG=/etc/kubernetes/admin.conf

# Deploy Calico network
echo "[TASK 3] Deploy Calico network"
kubectl apply -f https://docs.projectcalico.org/v3.8/manifests/calico.yaml

# Generate Cluster join command
echo "[TASK 4] Generate and save cluster join command to /home/vagrant/joincluster.sh"
kubeadm token create --print-join-command > /home/vagrant/joincluster.sh