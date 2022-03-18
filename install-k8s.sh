curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
apt-get -y install kubeadm=1.22.8-00 kubelet=1.22.8-00 kubectl=1.22.8-00
cat << EOF > /etc/docker/daemon.json
{
    "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl restart kubelet
echo "Manually issue 'sudo swapoff -a'"
echo "On master node:"
echo 
echo "sudo kubeadm init --pod-network-cidr=10.244.0.0/16"
echo "mkdir -p $HOME/.kube"
echo "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config"
echo "sudo chown $(id -u):$(id -g) $HOME/.kube/config"
echo
echo "Establish Flannel networking"
echo 
echo "sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"
echo
echo "Run kubeadm join command from the master on all other nodes."
