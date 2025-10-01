#!/usr/bin/env bash
set -euo pipefail

CA_DIR="${HOME}/.minikube"
CA_CRT="${CA_DIR}/ca.crt"
CA_KEY="${CA_DIR}/ca.key"
CLUSTER="minikube"

[[ -f "$CA_CRT" && -f "$CA_KEY" ]] || { echo "CA Minikube не найден. Запусти: minikube start"; exit 1; }

create_user () {
  local USER="$1" GROUP="$2"
  echo "==> Создаю ${USER} (O=${GROUP})"
  openssl genrsa -out "${USER}.key" 2048 >/dev/null 2>&1
  openssl req -new -key "${USER}.key" -out "${USER}.csr" -subj "/CN=${USER}/O=${GROUP}" >/dev/null 2>&1
  openssl x509 -req -in "${USER}.csr" -CA "${CA_CRT}" -CAkey "${CA_KEY}" -CAcreateserial -out "${USER}.crt" -days 365 >/dev/null 2>&1

  kubectl config set-credentials "${USER}" \
    --client-certificate="${USER}.crt" --client-key="${USER}.key" --embed-certs=true >/dev/null
  kubectl config set-context "${USER}-context" --cluster="${CLUSTER}" --user="${USER}" >/dev/null
}

# ДВА пользователя по заданию
create_user "user-reader" "group-viewer"
create_user "user-writer" "group-editor"

echo "Готово. Контексты: user-reader-context, user-writer-context"
