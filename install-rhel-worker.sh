#!/bin/bash

set -e

KUBERNETES_MINOR_VERSION=1.33.0
KUBERNETES_MAJOR_VERSION=v1.33
CRIO_VERSION=v1.32

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
 

dnf install -y container-selinux

dnf install -y cri-o kubelet kubeadm kubectl

mv /etc/cni/net.d/10-crio-bridge.conflist.disabled /etc/cni/net.d/10-crio-bridge.conflist

systemctl enable --now  crio.service
systemctl disable --now firewalld

swapoff -a
modprobe br_netfilter
sysctl -w net.ipv4.ip_forward=1

kubeadm init --kubernetes-version=${KUBERNETES_MINOR_VERSION} --ignore-preflight-errors=NumCPU --skip-token-print --pod-network-cidr 192.168.0.0/16

mkdir -p ~/.kube
cp -i /etc/kubernetes/admin.conf ~/.kube/config

### CNI
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
echo $CILIUM_CLI_VERSION
CLI_ARCH=amd64
#if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

/usr/local/bin/cilium install --version 1.17.2

echo "### COMMAND TO ADD A WORKER NODE ###"
kubeadm token create --print-join-command --ttl 0

### setup terminal
echo 'colorscheme default' >> ~/.vimrc
echo 'set tabstop=2' >> ~/.vimrc
echo 'set shiftwidth=2' >> ~/.vimrc
echo 'set expandtab' >> ~/.vimrc
echo 'source <(kubectl completion bash)' >> ~/.bashrc
echo 'alias k=kubectl' >> ~/.bashrc
echo 'alias c=clear' >> ~/.bashrc
echo 'complete -F __start_kubectl k' >> ~/.bashrc
sed -i '1s/^/force_color_prompt=yes\n/' ~/.bashrc
echo 'source ~/kube-ps1.sh' >>~root/.bashrc
echo "PS1='[\u@\h \W \$(kube_ps1)]\$ '" >>~root/.bashrc

echo
echo "EXECUTE ON MASTER: kubeadm token create --print-join-command --ttl 0"
echo "THEN RUN THE OUTPUT AS COMMAND HERE TO ADD AS WORKER"
echo

exit $?
