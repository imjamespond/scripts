```
hostnamectl set-hostname 'k8s-master1'
echo '192.168.0.247 k8s-master1' >> /etc/hosts
```

## Installing kubeadm
```
free -h
blkid 
lsblk 
swapoff -a 
vi /etc/fstab
mount -a
```

### Letting iptables see bridged traffic
`` lsmod | grep br_netfilter ``  
`` sudo modprobe br_netfilter ``
```
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1

net.ipv4.ip_forward = 1
EOF
sudo sysctl --system
```
### Check required ports 
```
ports=("6443" "2379-2380" "10250" "10251" "10252" "30000-32767")
for i in "${ports[@]}"
do
  firewall-cmd --permanent --add-port=${i}/tcp
done
firewall-cmd --reload
```

### Installing runtime (Docker...) 

### Installing kubeadm, kubelet and kubectl
```
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF
# 阿里源
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

# Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# sudo can not use proxy env
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

sudo systemctl enable --now kubelet
```

### Configure cgroup driver used by kubelet on control-plane node
`` /var/lib/kubelet/config.yaml``
```
systemctl daemon-reload
systemctl restart kubelet
```


## Bootstaping cluster
```
1, specify the --control-plane-endpoint
2, set the --pod-network-cidr to a provider-specific value.
3,
4, To use a different network interface, specify the --apiserver-advertise-address=<ip-address> argument to kubeadm init
5, Run kubeadm config images pull prior to kubeadm init

kubeadm config images list --kubernetes-version 1.18.3
https://cr.console.aliyun.com/cn-hangzhou/instances/credentials
sudo docker login --username=james_huangjian@163.com registry.cn-hangzhou.aliyuncs.com
images=(
  kube-apiserver:v1.18.3
  kube-controller-manager:v1.18.3
  kube-scheduler:v1.18.3
  kube-proxy:v1.18.3
  pause:3.2
  etcd:3.4.3-0
  coredns:1.6.7
)
for imageName in ${images[@]} ; do
    docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
    docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName k8s.gcr.io/$imageName
    docker rmi registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
done
kubeadm config print init-defaults KubeProxyConfiguration --component-configs KubeProxyConfiguration > kubeadm.conf
kubeadm init --control-plane-endpoint=192.168.0.247 --apiserver-advertise-address=192.168.0.247 --kubernetes-version 1.18.3
kubeadm init --config ./kubeadm.conf # controlPlaneEndpoint,kubernetesVersion在ClusterConfiguration, advertiseAddress在InitConfiguration
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
# For root
export KUBECONFIG=/etc/kubernetes/admin.conf
kubeadm join 192.168.0.247:6443 --token betkph.54rq517c9cdxldf0 \
  --discovery-token-ca-cert-hash sha256:119f89fd6074933efec8526a9adc92042dbc2bfd69ff47ec58eb0da15b0ee1e6 \
  --control-plane # 作为master? 
```
### If you wish to reset iptables  
``iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X``  
### If your cluster was setup to utilize IPVS  
``run ipvsadm --clear``  

## Installing a Pod network add-on 这一步成功dns才能启动
``kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml``  

``curl http://localhost:10249/proxyMode``