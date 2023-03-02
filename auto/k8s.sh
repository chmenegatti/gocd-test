#!/usr/bin/env bash

sed -i "s~#{image}~$ARTIFACT_IMAGE~g" deployment.json

if [ -z $KUBE_TOKEN ]; then
  echo "FATAL: Environment Variable KUBE_TOKEN must be specified."
  exit ${2:-1}
fi

if [ -z $NAMESPACE ]; then
  echo "FATAL: Environment Variable NAMESPACE must be specified."
  exit ${2:-1}
fi

echo
echo "Namespace $NAMESPACE"
echo "Authorization: Bearer $KUBE_TOKEN"

status_code=$(curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/apps/v1/namespaces/$NAMESPACE/deployments/gocd-test" \
    -X GET -o /dev/null -w "%{http_code}")

if [ $status_code == 200 ]; then
  echo
  echo "Updating deployment"
  curl --fail -H 'Content-Type: application/strategic-merge-patch+json' -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/apps/v1/namespaces/$NAMESPACE/deployments/gocd-test" \
    -X PATCH -d @deployment.json
else
 echo
 echo "Creating deployment"

 echo "$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/apps/v1/namespaces/$NAMESPACE/deployments"
 echo
 curl --fail -H 'Content-Type: application/json' -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
    "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/apps/v1/namespaces/$NAMESPACE/deployments" \
    -X POST -d @deployment.json
fi

# status_code=$(curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
#     "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/$NAMESPACE/services/bulletin-board-service" \
#     -X GET -o /dev/null -w "%{http_code}")

# if [ $status_code == 404 ]; then
#  echo
#  echo "Creating service"
#  curl --fail -H 'Content-Type: application/json' -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
#     "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/$NAMESPACE/services" \
#     -X POST -d @bulletin-board-service.json
# fi

# status_code=$(curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
#     "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/extensions/v1beta1/namespaces/$NAMESPACE/ingresses/bulletin-board-ingress" \
#     -X GET -o /dev/null -w "%{http_code}")

# if [ $status_code == 404 ]; then
#  echo
#  echo "Creating ingress"
#  curl --fail -H 'Content-Type: application/json' -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
#     "https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/apis/extensions/v1beta1/namespaces/$NAMESPACE/ingresses" \
#     -X POST -d @bulletin-board-ingress.json
# fi