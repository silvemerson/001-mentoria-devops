---
layout: default
title: Terraform para GCP
permalink: /capitulos/terraform-gcp/
---


# Terraform para GCP

Neste capítulo vamos abordar os conceitos :

- Introdução ao Terraform: o que é e por que usar  
- Arquitetura do Terraform: providers, recursos, estados  
- Configuração de ambiente para GCP com Terraform  
- Escrevendo arquivos `.tf` para provisionar recursos GCP (VMs, redes, buckets)  
- Uso de variáveis, outputs e módulos para organização do código  
- Gerenciamento de estado remoto com backend (ex: GCS)  
- Boas práticas para versionamento e reutilização  
- Integração com pipelines CI/CD para deploy automatizado


Conceitos Essenciais de Terraform

Neste capítulo vamos abordar os conceitos fundamentais do **Terraform**
e seu uso prático na **Google Cloud Platform (GCP)**.

## Introdução ao Terraform: o que é e por que usar

O Terraform é uma ferramenta de **Infraestrutura como Código (IaC)** que
permite criar, gerenciar e versionar recursos de infraestrutura em
diferentes provedores de nuvem. Ele é amplamente utilizado por sua
capacidade de automatizar provisionamentos e manter consistência entre
ambientes.\
Com o Terraform, a infraestrutura passa a ser tratada como código,
permitindo maior controle, auditoria e reprodutibilidade.

## Arquitetura do Terraform: providers, recursos, estados

O funcionamento do Terraform é baseado em alguns componentes
principais: - **Providers**: plugins que permitem interagir com
diferentes provedores de nuvem (como GCP, AWS, Azure, etc.).\
- **Recursos (resources)**: definem os objetos a serem criados, como
VMs, redes e buckets.\
- **Estado (state)**: arquivo que mantém o rastreamento da
infraestrutura real, garantindo que o Terraform saiba o que já existe.

## Configuração de ambiente para GCP com Terraform

Para utilizar o Terraform na GCP é necessário configurar credenciais de
acesso, geralmente utilizando um **Service Account**.\
Além disso, o SDK da Google Cloud pode auxiliar no gerenciamento de
permissões e credenciais.\
Essa configuração garante que o Terraform consiga autenticar e manipular
os recursos na nuvem.

## Escrevendo arquivos `.tf` para provisionar recursos GCP (VMs, redes, buckets)

Os arquivos com extensão `.tf` descrevem os recursos que devem ser
criados.\
Exemplo de recursos comuns: - **VMs (Compute Engine)**\
- **Redes e sub-redes (VPCs)**\
- **Buckets (Cloud Storage)**

Cada recurso é definido de forma declarativa, permitindo que o Terraform
crie e mantenha o estado desejado.

## Uso de variáveis, outputs e módulos para organização do código

O Terraform oferece mecanismos para tornar o código mais organizado e
reutilizável: - **Variáveis**: permitem parametrizar configurações,
evitando valores fixos.\
- **Outputs**: expõem informações importantes após a criação de
recursos.\
- **Módulos**: agrupam configurações reutilizáveis, facilitando a
padronização entre projetos.

## Gerenciamento de estado remoto com backend (ex: GCS)

O arquivo de estado do Terraform pode ser armazenado localmente ou em
backends remotos.\
Na GCP, o backend mais comum é o **Google Cloud Storage (GCS)**, que
permite compartilhar o estado entre diferentes times e pipelines,
garantindo consistência no provisionamento.

## Boas práticas para versionamento e reutilização

-   Usar **controle de versão (Git)** para acompanhar alterações.\
-   Separar ambientes (dev, staging, prod) em workspaces ou diretórios
    diferentes.\
-   Reutilizar módulos para evitar duplicação de código.\
-   Documentar variáveis e outputs para facilitar manutenção.

## Integração com pipelines CI/CD para deploy automatizado

O Terraform pode ser integrado a pipelines de **CI/CD** em ferramentas
como **GitHub Actions, GitLab CI e Jenkins**.\
Essa integração possibilita que o provisionamento de infraestrutura seja
parte do ciclo de entrega contínua, garantindo agilidade, segurança e
padronização.

------------------------------------------------------------------------

Esses conceitos fornecem a base necessária para utilizar o Terraform de
forma eficiente, especialmente no contexto de provisionamento e
automação de recursos na GCP.


---

Voltar ao [Sumário](../README.md)