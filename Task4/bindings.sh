#!/usr/bin/env bash
set -euo pipefail

# 1) Глобальные привязки групп к кластерным ролям
kubectl apply -f - <<'YAML'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata: { name: viewer-to-group-viewer }
subjects:
- kind: Group
  name: group-viewer
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-viewer
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata: { name: editor-to-group-editor }
subjects:
- kind: Group
  name: group-editor
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: project-editor
YAML

# 2) Точечный доступ SecOps к секретам в нужных ns
NS_LIST=(sales utilities)
for ns in "${NS_LIST[@]}"; do
  kubectl get ns "${ns}" >/dev/null 2>&1 || kubectl create ns "${ns}" >/dev/null
  kubectl -n "${ns}" create rolebinding secops-secrets \
    --clusterrole=secops-secrets-reader \
    --group=group-secops \
    --dry-run=client -o yaml | kubectl apply -f -
done

echo "Биндинги применены."
