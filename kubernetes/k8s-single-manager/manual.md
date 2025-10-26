# Provisionar Ambiente Kubernetes com CRI-O

## 1. Preparar o Sistema

```bash
# Habilitar encaminhamento IP permanentemente
sudo tee -a /etc/sysctl.conf > /dev/null <<EOF
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
EOF

sudo sysctl --system

# Desabilitar swap (obrigatório para Kubernetes)
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Carregar módulos necessários
sudo tee /etc/modules-load.d/k8s.conf > /dev/null <<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter
```

## 2. Instalar CRI-O

```bash
# Definir versões
export OS=xUbuntu_22.04  # Ajuste conforme sua distro
export CRIO_VERSION=1.30

# Adicionar repositório CRI-O
curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/stable:/v${CRIO_VERSION}/deb/Release.key | \
    sudo gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://pkgs.k8s.io/addons:/cri-o:/stable:/v${CRIO_VERSION}/deb/ /" | \
    sudo tee /etc/apt/sources.list.d/cri-o.list

# Instalar CRI-O
sudo apt-get update
sudo apt-get install -y cri-o

# Iniciar e habilitar CRI-O
sudo systemctl daemon-reload 
sudo systemctl enable crio 
sudo systemctl start crio

# Verificar status
sudo systemctl status crio

# Configurar crictl
sudo tee /etc/crictl.yaml > /dev/null <<EOF
runtime-endpoint: unix:///var/run/crio/crio.sock
image-endpoint: unix:///var/run/crio/crio.sock
timeout: 10
debug: false
EOF
```

## 3. Instalar Kubernetes

```bash
# Instalar dependências
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Adicionar repositório Kubernetes
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | \
    sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | \
    sudo tee /etc/apt/sources.list.d/kubernetes.list

# Instalar componentes Kubernetes
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Habilitar kubelet
sudo systemctl enable kubelet
```

## 4. Inicializar Cluster (SOMENTE NO MASTER)

```bash
# Pull das imagens do Kubernetes
sudo kubeadm config images pull --cri-socket unix:///var/run/crio/crio.sock

# Inicializar o cluster
sudo kubeadm init \
  --pod-network-cidr=192.168.0.0/16 \
  --cri-socket=unix:///var/run/crio/crio.sock \
  --apiserver-advertise-address=192.168.56.10

# Configurar kubectl para usuário regular
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# IMPORTANTE: Salve o comando 'kubeadm join' exibido no final!


Nas 3 VMS configure de acordo com o IP de cada Node:

sudo vim /etc/default/kubelet
KUBELET_EXTRA_ARGS='--node-ip 192.168.56.xx'

```

## 5. Instalar CNI - Calico (SOMENTE NO MASTER)

```bash
# Instalar Calico
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.0/manifests/custom-resources.yaml

# Aguardar pods ficarem prontos (pode levar 2-3 minutos)
ubectl get pods -n kube-system 

# Verificar node pronto
kubectl get nodes
```

## 6. Adicionar Workers ao Cluster (SOMENTE NOS WORKERS)

```bash
# Execute nos workers o comando fornecido pelo 'kubeadm init'
# Exemplo:
sudo kubeadm join 192.168.56.10:6443 --token <token> \
    --discovery-token-ca-cert-hash sha256:<hash> \
    --cri-socket=unix:///var/run/crio/crio.sock
```

## 7. Validação do Cluster

```bash
# Verificar nodes
kubectl get nodes -o wide

# Verificar pods do sistema
kubectl get pods -A

# Verificar status do CRI-O
sudo crictl info | grep -E "RuntimeVersion|RuntimeName"
sudo systemctl status crio

# Testar criação de pod
kubectl run nginx --image=nginx
kubectl get pods
kubectl delete pod nginx

# Ver logs de um pod específico (se houver problemas)
kubectl describe node <node-name>
kubectl logs -n kube-system <pod-name>
```

## 8. Configurações Adicionais (Opcionais)

### Habilitar autocompletar kubectl
```bash
echo 'source <(kubectl completion bash)' >> ~/.bashrc
echo 'alias k=kubectl' >> ~/.bashrc
echo 'complete -o default -F __start_kubectl k' >> ~/.bashrc
source ~/.bashrc
```

### Remover taint do master (para permitir pods no master)
```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

### Instalar Metrics Server (para kubectl top)
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Se houver erro de certificado TLS, editar deployment:
kubectl edit deployment metrics-server -n kube-system
# Adicionar: --kubelet-insecure-tls na seção args
```

## Troubleshooting

### Se o CRI-O não iniciar
```bash
sudo journalctl -xeu crio
sudo crio --log-level=debug
```

### Se o kubelet falhar
```bash
sudo journalctl -xeu kubelet
sudo systemctl status kubelet
```

### Resetar configuração (caso necessário)
```bash
sudo kubeadm reset --cri-socket=unix:///var/run/crio/crio.sock
sudo rm -rf /etc/cni/net.d
sudo rm -rf $HOME/.kube/config
sudo systemctl restart crio
```

### Gerar novo token de join (no master)
```bash
kubeadm token create --print-join-command
```

---


## Referências

- [Documentação Oficial Kubernetes](https://kubernetes.io/docs/)
- [CRI-O Documentation](https://cri-o.io/)
- [Calico Documentation](https://docs.tigera.io/calico/latest/about/)
- [kubeadm Installation Guide](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/)