# Provisionar Cluster Kubernetes HA Multi control-plane com CRI-O

Este guia configura um cluster Kubernetes de alta disponibilidade com 3 masters, 2 workers e 1 load balancer usando CRI-O como runtime.

## Topologia do Cluster

```
┌─────────────────────┐
│   Load Balancer     │ 192.168.56.10 (HAProxy)
│   k8s-loadbalancer  │
└──────────┬──────────┘
           │
    ┌──────┴──────┬──────────┐
    │             │          │
┌───▼────┐   ┌───▼────┐   ┌─▼──────┐
│Master 1│   │Master 2│   │Master 3│
│ .11    │   │ .12    │   │ .13    │
└────────┘   └────────┘   └────────┘
                 │
         ┌───────┴────────┐
         │                │
    ┌────▼───┐       ┌────▼───┐
    │Worker 1│       │Worker 2│
    │  .21   │       │  .22   │
    └────────┘       └────────┘
```

## 1. Configurar Load Balancer (k8s-loadbalancer)

### Instalar e configurar HAProxy

```bash
# Instalar HAProxy
sudo apt-get update
sudo apt-get install -y haproxy

# Backup da configuração original
sudo cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.bak

# Criar nova configuração
sudo tee /etc/haproxy/haproxy.cfg > /dev/null <<EOF
global
    log /dev/log local0
    log /dev/log local1 notice
    daemon
    maxconn 4096
    user haproxy
    group haproxy

defaults
    log     global
    mode    tcp
    option  tcplog
    option  dontlognull
    timeout connect 10s
    timeout client  1m
    timeout server  1m
    retries 3

# Frontend para Kubernetes API Server
frontend k8s-api
    bind *:6443
    mode tcp
    option tcplog
    default_backend k8s-masters

# Backend com os masters
backend k8s-masters
    mode tcp
    balance roundrobin
    option tcp-check
    default-server inter 10s downinter 5s rise 2 fall 3 slowstart 60s maxconn 250 maxqueue 256 weight 100
    server k8s-master-1 192.168.56.11:6443 check
    server k8s-master-2 192.168.56.12:6443 check
    server k8s-master-3 192.168.56.13:6443 check

# Stats page (opcional, mas útil)
listen stats
    bind *:8080
    mode http
    stats enable
    stats uri /
    stats refresh 30s
    stats realm Haproxy\ Statistics
    stats auth admin:admin
EOF

# Reiniciar HAProxy
sudo systemctl restart haproxy
sudo systemctl enable haproxy

# Verificar status
sudo systemctl status haproxy

# Verificar se está escutando na porta 6443
sudo ss -tlnp | grep 6443
```

### Testar HAProxy

```bash
# Verificar logs
sudo tail -f /var/log/haproxy.log

# Testar conectividade (após inicializar os masters)
nc -zv 192.168.56.10 6443
```

## 2. Preparar TODOS os Nodes (Masters e Workers)

Execute os comandos abaixo em **todos os masters e workers**:

```bash
# Habilitar encaminhamento IP e parâmetros de rede
sudo tee -a /etc/sysctl.conf > /dev/null <<EOF
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
EOF

sudo sysctl --system

# Desabilitar swap
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Carregar módulos necessários
sudo tee /etc/modules-load.d/k8s.conf > /dev/null <<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Configurar /etc/hosts para resolução de nomes
sudo tee -a /etc/hosts > /dev/null <<EOF
192.168.56.10   k8s-loadbalancer
192.168.56.11   k8s-master-1
192.168.56.12   k8s-master-2
192.168.56.13   k8s-master-3
192.168.56.21   k8s-worker-1
192.168.56.22   k8s-worker-2
EOF
```

## 3. Instalar CRI-O em TODOS os Nodes (Masters e Workers)

```bash
# Definir versões
export OS=xUbuntu_22.04
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

## 4. Instalar Kubernetes em TODOS os Nodes (Masters e Workers)

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

## 5. Inicializar o Primeiro Master (k8s-master-1)

```bash
# Pull das imagens do Kubernetes
sudo kubeadm config images pull --cri-socket unix:///var/run/crio/crio.sock

# Inicializar o cluster
sudo kubeadm init \
  --control-plane-endpoint "192.168.56.10:6443" \
  --upload-certs \
  --pod-network-cidr=192.168.0.0/16 \
  --cri-socket=unix:///var/run/crio/crio.sock \
  --apiserver-advertise-address=192.168.56.11

# IMPORTANTE: Salve os comandos de join exibidos no final!
# Haverá dois comandos:
# 1. Para adicionar control-plane nodes (outros masters)
# 2. Para adicionar worker nodes

# Configurar kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Verificar cluster
kubectl get nodes
kubectl get pods -A
```

## 6. Adicionar Outros Masters (k8s-master-2 e k8s-master-3)

Execute em **k8s-master-2** e **k8s-master-3**:

```bash
# Use o comando fornecido pelo kubeadm init
# Exemplo:
sudo kubeadm join 192.168.56.10:6443 \
  --token <TOKEN> \
  --discovery-token-ca-cert-hash sha256:<HASH> \
  --control-plane \
  --certificate-key <CERTIFICATE-KEY> \
  --cri-socket=unix:///var/run/crio/crio.sock \
  --apiserver-advertise-address=<IP-DO-MASTER>


  # kubeadm join 192.168.56.10:6443 --token szw1o2.7ozlv1iwiumiu7pk \
	# --discovery-token-ca-cert-hash sha256:35382e0689fe900ad1668e334766d6f4fde119f05672a7998a2c11de4521952b \
	# --control-plane --certificate-key e55228c9f193ebd9efecd1443b332941da3e563d296034cf7abe9c4c63a8c65a \
  # --cri-socket=unix:///var/run/crio/crio.sock \
  # --apiserver-advertise-address=192.168.56.13


# Para master-2: --apiserver-advertise-address=192.168.56.12
# Para master-3: --apiserver-advertise-address=192.168.56.13

# Configurar kubectl em cada master
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### Se o certificado expirou (válido por 2 horas)

```bash
# No master-1, gerar novo certificate key
sudo kubeadm init phase upload-certs --upload-certs

# Use o novo certificate-key no comando join
```

## 7. Instalar CNI - Calico (SOMENTE NO MASTER-1)

```bash
# Instalar Calico, copieio calico.yaml para a VM
# kubectl create -f kubectl calico.yaml

# Aguardar pods ficarem prontos (pode levar 2-3 minutos)
watch kubectl get pods -n kube-system

# Verificar nodes prontos
kubectl get nodes
```

## 8. Adicionar Workers (k8s-worker-1 e k8s-worker-2)

Execute em **k8s-worker-1** e **k8s-worker-2**:

```bash
# Use o comando fornecido pelo kubeadm init (comando para workers)
# Exemplo:
sudo kubeadm join 192.168.56.10:6443 \
  --token <TOKEN> \
  --discovery-token-ca-cert-hash sha256:<HASH> \
  --cri-socket=unix:///var/run/crio/crio.sock


# kubeadm join 192.168.56.10:6443 --token szw1o2.7ozlv1iwiumiu7pk \
# 	--discovery-token-ca-cert-hash sha256:35382e0689fe900ad1668e334766d6f4fde119f05672a7998a2c11de4521952b \
#   --cri-socket=unix:///var/run/crio/crio.sock

```



### Se o token expirou

```bash
# No master-1, gerar novo token
kubeadm token create --print-join-command
```

## 9. Validação do Cluster HA

```bash
# Verificar todos os nodes
kubectl get nodes -o wide

# Deve mostrar:
# - 3 masters com role "control-plane"
# - 2 workers com role "<none>"
# - Todos com STATUS "Ready"

# Verificar pods do sistema
kubectl get pods -A -o wide

# Verificar componentes de HA
kubectl get pods -n kube-system | grep -E "kube-apiserver|etcd|kube-controller|kube-scheduler"

# Verificar endpoints do API server
kubectl get endpoints

# Verificar status do CRI-O
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.nodeInfo.containerRuntimeVersion}{"\n"}{end}'

# Testar alta disponibilidade
# Simular falha de um master
sudo systemctl stop kubelet  # Em um dos masters

# Verificar que o cluster continua funcionando
kubectl get nodes  # Executar de outro master
```

## 10. Testes de Alta Disponibilidade

### Teste 1: Desligar master-1

```bash
# No master-1
sudo systemctl stop kubelet
sudo systemctl stop crio

# No master-2 ou master-3
kubectl get nodes
kubectl run test-nginx --image=nginx
kubectl get pods

# Religar master-1
sudo systemctl start crio
sudo systemctl start kubelet
```

### Teste 2: Verificar distribuição de carga no HAProxy

```bash
# No load balancer, acessar stats
# Navegador: http://192.168.56.10:8080
# Usuário: admin
# Senha: admin

# Ou via curl
curl http://admin:admin@192.168.56.10:8080
```

### Teste 3: Verificar etcd cluster

```bash
# Em qualquer master
sudo crictl ps | grep etcd

# Verificar membros do etcd
kubectl exec -n kube-system etcd-k8s-master-1 -- etcdctl \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  member list
```

## 11. Configurações Adicionais (Opcionais)

### Habilitar autocompletar kubectl em todos os masters

```bash
echo 'source <(kubectl completion bash)' >> ~/.bashrc
echo 'alias k=kubectl' >> ~/.bashrc
echo 'complete -o default -F __start_kubectl k' >> ~/.bashrc
source ~/.bashrc
```

### Instalar Metrics Server

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Editar para ambientes de teste (se necessário)
kubectl edit deployment metrics-server -n kube-system
# Adicionar: --kubelet-insecure-tls na seção args
```

### Instalar Dashboard Kubernetes (Opcional)

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# Criar usuário admin
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

# Obter token
kubectl -n kubernetes-dashboard create token admin-user

# Acessar dashboard
kubectl proxy
# URL: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

## 12. Backup e Recuperação

### Backup do etcd

```bash
# Em qualquer master
sudo ETCDCTL_API=3 etcdctl snapshot save /tmp/etcd-backup.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key

# Verificar backup
sudo ETCDCTL_API=3 etcdctl snapshot status /tmp/etcd-backup.db
```

### Backup dos certificados

```bash
# Em master-1
sudo tar -czf /tmp/k8s-certs-backup.tar.gz /etc/kubernetes/pki/
```

## Troubleshooting

### Masters não entram no cluster

```bash
# Verificar logs do kubelet
sudo journalctl -u kubelet -f

# Verificar se o HAProxy está funcionando
curl -k https://192.168.56.10:6443

# Verificar conectividade entre masters
ping 192.168.56.11
ping 192.168.56.12
ping 192.168.56.13
```

### Pods não iniciam

```bash
# Verificar logs do CRI-O
sudo journalctl -u crio -f

# Verificar logs do Calico
kubectl logs -n calico-system -l k8s-app=calico-node

# Verificar rede
kubectl get pods -n calico-system
```

### Resetar um node

```bash
sudo kubeadm reset --cri-socket=unix:///var/run/crio/crio.sock
sudo rm -rf /etc/cni/net.d
sudo rm -rf $HOME/.kube/config
sudo systemctl restart crio
sudo systemctl restart kubelet
```

### Gerar novos tokens

```bash
# Token para workers
kubeadm token create --print-join-command

# Token e certificate-key para masters
kubeadm token create --print-join-command
kubeadm init phase upload-certs --upload-certs
```

## Arquitetura de Alta Disponibilidade

### Componentes Redundantes

- **3 Masters**: Cada um executa:
  - kube-apiserver
  - kube-controller-manager (leader election)
  - kube-scheduler (leader election)
  - etcd (cluster com 3 membros)

- **HAProxy**: Distribui requisições entre os 3 API servers

- **etcd**: Cluster com quorum (maioria de 2 de 3 nodes)

### Resiliência

- ✅ **1 master falha**: Cluster continua operando (quorum: 2/3)
- ❌ **2 masters falham**: Cluster fica read-only (sem quorum)
- ✅ **HAProxy falha**: Acessar API server diretamente em qualquer master

## Notas Importantes

- **Quorum do etcd**: Necessário 2 de 3 nodes funcionando
- **Certificate-key**: Expira em 2 horas após geração
- **Tokens**: Expiram em 24 horas por padrão
- **HAProxy**: Porta 6443 deve estar acessível de todos os nodes
- **Firewall**: Liberar portas necessárias entre todos os nodes
- **CRI-O**: Runtime mais leve que containerd/Docker
- **Rede Pod**: CIDR 192.168.0.0/16 é padrão do Calico

## Portas Necessárias

### Masters
- 6443: Kubernetes API (via HAProxy)
- 2379-2380: etcd
- 10250: kubelet API
- 10259: kube-scheduler
- 10257: kube-controller-manager

### Workers
- 10250: kubelet API
- 30000-32767: NodePort Services

### Load Balancer
- 6443: HAProxy para API server
- 8080: HAProxy stats (opcional)

## Referências

- [Kubernetes HA Clusters](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/)
- [HAProxy Documentation](http://www.haproxy.org/)
- [CRI-O Documentation](https://cri-o.io/)
- [Calico Documentation](https://docs.tigera.io/calico/latest/about/)
- [etcd Documentation](https://etcd.io/docs/)