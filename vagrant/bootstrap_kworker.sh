#!/bin/bash

echo "Boostrapping k8s worker..."

export DEBIAN_FRONTEND=noninteractive

# Join worker nodes to the Kubernetes cluster
echo "[TASK 1] Join node to Kubernetes Cluster"
apt-get install -y sshpass
sshpass -p "vagrant" scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no vagrant@kmaster:/home/vagrant/joincluster.sh /home/vagrant/joincluster.sh 2>/dev/null

echo "Joining the cluster..."
bash /home/vagrant/joincluster.sh >/dev/null 2>&1