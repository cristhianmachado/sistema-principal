#!/usr/bin/env bash
# =============================================================================
# FLUXO DE SUBMÓDULOS GIT — Guia passo-a-passo (vibecoding)
# -----------------------------------------------------------------------------
# Design system (design-system-components) consumido por dois projetos
# (sistema-principal e painel-admin) via `git submodule`.
#
# Este arquivo é DIDÁTICO: leia os blocos e rode os comandos que quiser.
# NÃO execute tudo de uma vez sem entender cada etapa.
#
# Contas/URLs deste experimento (conta GitHub: cristhianmachado):
#   DS:       https://github.com/cristhianmachado/design-system-components.git
#   Consumo1: https://github.com/cristhianmachado/sistema-principal.git
#   Consumo2: https://github.com/cristhianmachado/painel-admin.git
# =============================================================================

set -euo pipefail

DS_URL="https://github.com/cristhianmachado/design-system-components.git"
APP_URL="https://github.com/cristhianmachado/sistema-principal.git"

# -----------------------------------------------------------------------------
# NOTA DE AMBIENTE (específico desta máquina):
# A config global tem core.hooksPath apontando para um caminho que não existe,
# o que quebra `git commit`. Nestes repos usamos hooksPath local vazio:
#   git config core.hooksPath /dev/null
# Se no seu ambiente os hooks funcionam, ignore essa linha.
# -----------------------------------------------------------------------------


# =============================================================================
# PARTE 1 — CRIAR O REPOSITÓRIO DO DESIGN SYSTEM (o futuro submódulo)
# =============================================================================
parte1_criar_design_system() {
  mkdir -p design-system-components && cd design-system-components

  git init -b main
  git config core.hooksPath /dev/null      # contorno do ambiente (ver nota acima)

  # ... aqui você cria os componentes (Button, Card, index.ts) ...

  git add -A
  git commit -m "chore: initial commit (design-system-components)"

  # Publica no GitHub (gh CLI). --public ou --private conforme necessidade.
  gh repo create cristhianmachado/design-system-components \
    --public --source=. --remote=origin --push

  cd ..
}


# =============================================================================
# PARTE 2 — ADICIONAR O DS COMO SUBMÓDULO NO PROJETO PRINCIPAL
# =============================================================================
parte2_adicionar_submodulo() {
  # (assumindo que sistema-principal já existe, com git init + repo remoto)
  cd sistema-principal
  git config core.hooksPath /dev/null

  # Monta o submódulo na pasta src/components/shared apontando para o repo do DS.
  # Isso cria/atualiza o arquivo .gitmodules e faz um clone do DS naquela pasta.
  git submodule add "$DS_URL" src/components/shared

  # O commit registra DUAS coisas no projeto principal:
  #   1) o arquivo .gitmodules (path + url)
  #   2) o "gitlink": o COMMIT EXATO do DS que este projeto está usando (pin)
  git add .gitmodules src/components/shared
  git commit -m "feat: add design-system como submódulo em src/components/shared"
  git push origin main

  cd ..
}


# =============================================================================
# PARTE 3 — CLONAR O PROJETO PRINCIPAL JÁ COM O SUBMÓDULO (outra máquina/pessoa)
# =============================================================================
parte3_clonar_com_submodulo() {
  # OPÇÃO A (recomendada): clona e já traz os submódulos numa tacada.
  git clone --recursive "$APP_URL" sistema-principal-clone

  # OPÇÃO B: se clonou SEM --recursive, a pasta do submódulo vem VAZIA.
  #   Rode isto dentro do projeto para baixar o conteúdo do submódulo:
  #     git submodule update --init --recursive
  #
  # Exemplo da opção B:
  #   git clone "$APP_URL" sistema-principal-clone
  #   cd sistema-principal-clone
  #   git submodule update --init --recursive
  #   cd ..
}


# =============================================================================
# PARTE 4 — ALTERAR O DESIGN SYSTEM E PROPAGAR A MUDANÇA AOS CONSUMIDORES
# =============================================================================
# Fluxo real do dia-a-dia: você mexe no DS, publica, e cada consumidor
# decide QUANDO "subir" para a nova versão (atualizar o pin do submódulo).
# =============================================================================
parte4_alterar_ds_e_propagar() {
  # ---- 4.1) Fazer a alteração NO REPOSITÓRIO DO DESIGN SYSTEM ----------------
  # Você pode editar diretamente o repo do DS OU editar dentro da pasta do
  # submódulo de um consumidor (a pasta do submódulo É um repo Git do DS).
  cd sistema-principal/src/components/shared     # entra no repo do DS (submódulo)

  git checkout main
  git pull origin main                           # garante estar atualizado

  # ... edite um componente, ex: mudar o texto/estilo do Button ...
  # echo "// nova mudança" >> src/registry/ui/button.tsx

  git config core.hooksPath /dev/null
  git add -A
  git commit -m "feat: ajuste visual no Button"
  git push origin main                           # publica a mudança no DS
  NEW_DS_COMMIT=$(git rev-parse HEAD)
  cd ../../../..                                 # volta para a raiz do projeto principal

  # ---- 4.2) Atualizar o PIN do submódulo no PROJETO PRINCIPAL ----------------
  cd sistema-principal
  git config core.hooksPath /dev/null

  # O submódulo agora aponta para o novo commit (feito em 4.1).
  # Se você editou de fora, sincronize o submódulo para o último main assim:
  #   git submodule update --remote --merge src/components/shared
  #
  # O projeto principal enxerga o submódulo com mudanças; precisa "gravar o pin":
  git add src/components/shared
  git commit -m "chore: bump submódulo design-system p/ $NEW_DS_COMMIT"
  git push origin main

  cd ..
  # A partir daqui, quem der `git pull` no projeto principal + 
  #   `git submodule update --init --recursive` recebe a versão nova do DS.
}


# =============================================================================
# PARTE 5 — ATUALIZAR O SUBMÓDULO PARA A ÚLTIMA VERSÃO (do lado do consumidor)
# =============================================================================
parte5_consumidor_puxa_atualizacao() {
  cd sistema-principal
  git pull origin main                           # traz o novo pin do submódulo

  # Baixa o conteúdo correspondente ao pin registrado:
  git submodule update --init --recursive

  # OU, para pular direto para o último main do DS (ignorando o pin):
  #   git submodule update --remote --merge
  #   git add src/components/shared && git commit -m "chore: bump submódulo"
  cd ..
}


# =============================================================================
# COMANDOS ÚTEIS DE INSPEÇÃO
# =============================================================================
uteis() {
  git submodule status                 # mostra o commit atual de cada submódulo
  git submodule foreach 'git log --oneline -1'
  cat .gitmodules                      # path + url dos submódulos
}


# =============================================================================
# REMOVER UM SUBMÓDULO (caso precise desfazer)
# =============================================================================
remover_submodulo() {
  # exemplo removendo src/components/shared
  git submodule deinit -f src/components/shared
  rm -rf .git/modules/src/components/shared
  git rm -f src/components/shared
  git commit -m "chore: remove submódulo design-system"
}

echo "Este é um guia. Chame as funções individualmente, ex:"
echo "  source FLUXO-SUBMODULOS.sh && parte3_clonar_com_submodulo"
