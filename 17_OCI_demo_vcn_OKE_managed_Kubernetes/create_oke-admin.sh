export KUBECONFIG=./kubeconfig
echo "-- Create service account"
kubectl apply -f oke-admin-service-account.yaml
echo "-- Get an authentication token for this account"
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep oke-admin | awk '{print $1}') |grep "^token"|awk -F ' ' '{ print $2 }'
