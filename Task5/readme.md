запустить скрипт ./up.sh или:

# 1) создать ns и сервисы
kubectl apply -f ./namespace.yaml
kubectl apply -f ./services.yaml

# 2) применить политику
kubectl -n app-demo apply -f ./non-admin-api-allow.yaml
