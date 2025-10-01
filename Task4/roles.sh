#!/usr/bin/env bash
set -euo pipefail


# cluster-viewer — чтение, без секретов
kubectl apply -f - <<'YAML'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata: { name: cluster-viewer }
rules:
- apiGroups: [""]
  resources: [pods, services, endpoints, configmaps, events, persistentvolumeclaims, persistentvolumes, namespaces]
  verbs: [get, list, watch]
- apiGroups: ["apps"]
  resources: [deployments, statefulsets, daemonsets, replicasets]
  verbs: [get, list, watch]
- apiGroups: ["batch"]
  resources: [jobs, cronjobs]
  verbs: [get, list, watch]
- apiGroups: ["networking.k8s.io"]
  resources: [ingresses, networkpolicies]
  verbs: [get, list, watch]
YAML

# project-editor — CRUD по типовым ресурсам, без секретов
kubectl apply -f - <<'YAML'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata: { name: project-editor }
rules:
- apiGroups: [""]
  resources: [pods, services, endpoints, configmaps, events, persistentvolumeclaims]
  verbs: [get, list, watch, create, update, patch, delete]
- apiGroups: ["apps"]
  resources: [deployments, statefulsets, daemonsets, replicasets]
  verbs: [get, list, watch, create, update, patch, delete]
- apiGroups: ["batch"]
  resources: [jobs, cronjobs]
  verbs: [get, list, watch, create, update, patch, delete]
- apiGroups: ["networking.k8s.io"]
  resources: [ingresses, networkpolicies]
  verbs: [get, list, watch, create, update, patch, delete]
YAML

# secops-secrets-reader — чтение только secrets (будет назначаться точечно по ns)
kubectl apply -f - <<'YAML'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata: { name: secops-secrets-reader }
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: [get, list, watch]
YAML

# admin — полный доступ (* на всё)
kubectl apply -f - <<'YAML'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata: { name: admin }
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
YAML

echo "Роли созданы: cluster-viewer, project-editor, secops-secrets-reader, admin"
