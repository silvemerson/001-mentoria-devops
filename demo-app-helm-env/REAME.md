# Environment Display App

Aplicação simples que exibe o ambiente atual (Dev, Homologação ou Produção) no navegador.

## Estrutura do Projeto

```
.
├── Dockerfile
├── index.html
├── Chart.yaml
├── templates/
│   ├── deployment.yaml
│   └── service.yaml
├── values-dev.yaml
├── values-homolog.yaml
└── values-prod.yaml
```

## Como Usar

### 1. Build da Imagem Docker

```bash
docker build -t environment-display:latest .
docker push environment-display:latest
```

### 2. Deploy com Helm

**Desenvolvimento:**
```bash
helm install dev-display ./chart -f values-dev.yaml
```

**Homologação:**
```bash
helm install hmg-display ./chart -f values-homolog.yaml
```

**Produção:**
```bash
helm install prod-display ./chart -f values-prod.yaml
```

### 3. Upgrade de Ambiente

```bash
helm upgrade prod-display ./chart -f values-prod.yaml
```

### 4. Verificar Status

```bash
kubectl get pods
kubectl get svc
```

### 5. Acessar a Aplicação

Para acessar localmente (port-forward):
```bash
kubectl port-forward svc/dev-environment-display 8080:80
```

Depois acesse: http://localhost:8080

## Características por Ambiente

### Dev
- **Réplicas:** 1
- **Recursos:** Mínimos (50m CPU, 64Mi RAM)
- **Cor:** Rosa/Vermelho

### Homologação
- **Réplicas:** 2
- **Recursos:** Médios (100m CPU, 128Mi RAM)
- **Cor:** Azul

### Produção
- **Réplicas:** 3
- **Recursos:** Máximos (250m CPU, 256Mi RAM)
- **Cor:** Verde

## Personalização

Para alterar o texto exibido, edite o arquivo `values-{ambiente}.yaml`:

```yaml
environment:
  name: prod
  displayName: "Produção"  # Mude aqui o texto
  class: "prod"            # Classe CSS (dev, homolog, prod)
```

## Desinstalar

```bash
helm uninstall nome-release
```