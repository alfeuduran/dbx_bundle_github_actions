# Pipeline de CI/CD com GitHub Actions

Este documento descreve o pipeline de CI/CD configurado com GitHub Actions para o projeto Databricks Asset Bundle.

## Estratégia de Branches

O projeto segue uma estratégia de três branches principais:

- `dev`: Branch de desenvolvimento, onde todo o trabalho de novos recursos é realizado
- `qa`: Branch de testes, onde os recursos são testados antes de irem para produção
- `prd`: Branch de produção, contendo o código que está em execução no ambiente de produção

## Fluxo de Trabalho

### 1. Desenvolvimento (dev)

O desenvolvimento é realizado na branch `dev` ou em branches de feature que são posteriormente mescladas em `dev`. Quando uma funcionalidade está pronta para testes:

1. Um PR é aberto de `dev` para `qa`
2. O workflow `.github/workflows/dev-to-qa.yml` é acionado, executando:
   - Verificação de qualidade de código (flake8, black, isort)
   - Testes unitários
   - Validação da estrutura do Asset Bundle

### 2. Testes (qa)

Quando o código passa por todos os testes e é mesclado em `qa`, está pronto para validação de integração. Quando tudo estiver pronto para produção:

1. Um PR é aberto de `qa` para `prd`
2. O workflow `.github/workflows/qa-to-prd.yml` é acionado, executando:
   - Testes de integração
   - Deploy para o ambiente de QA (preview do que será implantado em produção)
   - Validação da implantação de QA

### 3. Produção (prd)

Quando o PR de `qa` para `prd` é aprovado e mesclado:

1. O workflow `.github/workflows/deploy-to-prd.yml` é acionado, executando:
   - Deploy para o ambiente de produção
   - Verificação da implantação em produção (requer aprovação manual)
   - Criação de uma tag de versão

## GitHub Secrets Necessários

Para que o pipeline funcione corretamente, você precisa configurar os seguintes segredos no GitHub:

- `DATABRICKS_HOST`: URL do workspace Databricks
- `DATABRICKS_TOKEN`: Token de acesso para o Databricks

## Configurando um Novo Ambiente

1. Crie branches `dev`, `qa` e `prd`
2. Configure os secrets necessários
3. Configure um ambiente chamado "production" no GitHub com revisão obrigatória

## Referências

- [Databricks Asset Bundles](https://docs.databricks.com/dev-tools/bundles/index.html)
- [GitHub Actions](https://docs.github.com/en/actions) 