#!/bin/bash

set -e

KUBERNETES_MINOR_VERSION=1.33.1
KUBERNETES_MAJOR_VERSION=v1.33
CRIO_VERSION=v1.33

cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/$KUBERNETES_MAJOR_VERSION/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/$KUBERNETES_MAJOR_VERSION/rpm/repodata/repomd.xml.key
EOF

cat <<EOF | tee /etc/yum.repos.d/cri-o.repo
[cri-o]
name=CRI-O
baseurl=https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/rpm/
enabled=1
gpgcheck=1
gpgkey=https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/rpm/repodata/repomd.xml.key
EOF
 
dnf update -y 
dnf install -y container-selinux cri-o kubelet kubeadm kubectl

mv /etc/cni/net.d/10-crio-bridge.conflist.disabled /etc/cni/net.d/10-crio-bridge.conflist

systemctl enable --now  crio.service
systemctl disable --now firewalld
systemctl enable --now kubelet

swapoff -a
modprobe br_netfilter
sysctl -w net.ipv4.ip_forward=1

exit $?
