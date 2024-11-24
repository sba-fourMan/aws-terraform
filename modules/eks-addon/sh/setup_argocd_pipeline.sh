#!/bin/bash

ARGOCD_SERVER="<argocd-server>"
NAMESPACE="argocd"

# 로그인
argocd login ${ARGOCD_SERVER} \
  --username admin \
  --password $(kubectl get secret -n ${NAMESPACE} argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode)

# 애플리케이션 목록
declare -A APPS
APPS=(
  ["member"]="https://github.com/my-org/repo1.git|manifests1|my-namespace1"
  ["receipt"]="https://github.com/my-org/repo2.git|manifests2|my-namespace2"
  ["auction"]=""
  ["apigateway"]=""
)

# 애플리케이션 생성
for app in "${!APPS[@]}"; do
  IFS="|" read -r repo path namespace <<< "${APPS[$app]}"
  argocd app create $app \
    --repo $repo \
    --path $path \
    --dest-server https://kubernetes.app.svc \
    --dest-namespace $namespace \
    --sync-policy automated
done
