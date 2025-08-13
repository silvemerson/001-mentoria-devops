# Mentoria DevOps - Apostila

Repositório com a apostila da mentoria DevOps, organizada para GitHub Pages.

Para rodar localmente, recomendo usar Jekyll:

```bash
docker run --rm -p 4000:4000 -v $(pwd):/srv/jekyll -w /srv/jekyll ruby:3.1 bash -c "gem install bundler && bundle install && bundle exec jekyll serve --host 0.0.0.0"


```

## Roteiro de Conteúdo

## Sumário

- [1. Fundamentos de DevOps](#1-fundamentos-de-devops)  
- [2. Terraform para GCP](#2-terraform-para-gcp)  
- [3. Controle de Versão e Fluxos de Trabalho](#3-controle-de-versão-e-fluxos-de-trabalho)  
- [4. Docker — Contêineres na Prática](#4-docker--contêineres-na-prática)  
- [5. Kubernetes — Gerenciamento de Clusters e Objetos](#5-kubernetes--gerenciamento-de-clusters-e-objetos)  
- [6. Helm Charts — Automação de Deploys no Kubernetes](#6-helm-charts--automação-de-deploys-no-kubernetes)  
- [7. Pipelines no GitLab CI](#7-pipelines-no-gitlab-ci)  
- [8. Continuous Delivery com ArgoCD](#8-continuous-delivery-com-argocd)  
- [9. Observabilidade e Monitoramento](#9-observabilidade-e-monitoramento)  
- [10. Encerramento e Boas Práticas](#10-encerramento-e-boas-práticas)  

---

## 1. Fundamentos de DevOps

- Conceitos e princípios do DevOps  
- Cultura, colaboração e automação  
- Introdução a CI/CD  
- GitOps: práticas e benefícios  
- Infraestrutura como Código (IaC): visão geral  

---

## 2. Terraform para GCP

- Introdução ao Terraform: o que é e por que usar  
- Arquitetura do Terraform: providers, recursos, estados  
- Configuração de ambiente para GCP com Terraform  
- Escrevendo arquivos `.tf` para provisionar recursos GCP (VMs, redes, buckets)  
- Uso de variáveis, outputs e módulos para organização do código  
- Gerenciamento de estado remoto com backend (ex: GCS)  
- Boas práticas para versionamento e reutilização  
- Integração com pipelines CI/CD para deploy automatizado  

---

## 3. Controle de Versão e Fluxos de Trabalho

- Boas práticas de versionamento de código  
- Integração com pipelines de CI/CD  

---

## 4. Docker — Contêineres na Prática

- Conceitos básicos de contêineres  
- Criando imagens com Dockerfile (builds otimizados)  
- Trabalhando com volumes e persistência de dados  
- Melhores práticas de segurança e organização  

---

## 5. Kubernetes — Gerenciamento de Clusters e Objetos

- Arquitetura e componentes principais do Kubernetes  
- Criar nosso próprio cluster, cluster de desenvolvimento  
- Gerenciamento de namespaces, pods, deployments e services  
- Estratégias de escalabilidade e alta disponibilidade  
- RBAC e controle de acesso  
- Práticas de troubleshooting no cluster  

---

## 6. Helm Charts — Automação de Deploys no Kubernetes

- Introdução ao Helm e charts  
- Estrutura de um chart e templates  
- Versionamento e reuso de charts  
- Boas práticas na criação e manutenção  

---

## 7. Pipelines no GitLab CI

- Overview sobre o GitLab  
- Estrutura de um `.gitlab-ci.yml`  
- Runners  
- Integração com SonarQube para análise de código  
- Execução de testes de integração  
- Processo de build e empacotamento  
- Estratégias de pipelines eficientes  

---

## 8. Continuous Delivery com ArgoCD

- Conceitos e benefícios do CD no Kubernetes  
- Arquitetura e funcionamento do ArgoCD  
- Configuração de pipelines GitOps com ArgoCD  
- Estratégias de rollback e promoção entre ambientes  

---

## 9. Observabilidade e Monitoramento

- Introdução a métricas, logs e alertas  
- Configuração do Prometheus no Kubernetes  
- Dashboards e visualizações no Grafana  
- Monitoramento de desempenho e saúde do cluster  
- Introdução ao Dynatrace (integração e casos de uso)  

---

## 10. Encerramento e Boas Práticas

- Revisão dos conceitos-chave  
- Ferramentas e recursos para aprofundamento  
- Dicas de automação e otimização contínua  
- Próximos passos na jornada DevOps  
