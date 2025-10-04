#!/usr/bin/env bash
set -euo pipefail

NS="app-demo"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

NS_FILE="${ROOT_DIR}/namespace.yaml"
SVC_FILE="${ROOT_DIR}/services.yaml"
NP_FILE="${ROOT_DIR}/non-admin-api-allow.yaml"

echo "Применяем namespace..."
kubectl apply -f "$NS_FILE"

echo "Применяем сервисы"
kubectl apply -f "$SVC_FILE"

echo "Ждем развёртывания pod"
kubectl -n "$NS" rollout status deploy/front-end-app --timeout=60s
kubectl -n "$NS" rollout status deploy/back-end-api-app --timeout=60s
kubectl -n "$NS" rollout status deploy/admin-front-end-app --timeout=60s
kubectl -n "$NS" rollout status deploy/admin-back-end-api-app --timeout=60s

echo "Применяем сетевую политику"
kubectl -n "$NS" apply -f "$NP_FILE"

echo "Готово"
kubectl -n "$NS" get deploy,svc,po
