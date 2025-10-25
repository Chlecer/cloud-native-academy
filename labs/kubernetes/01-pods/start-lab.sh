#!/bin/bash

# Check if Minikube is running
if ! minikube status &> /dev/null; then
    echo "🚀 Starting Minikube..."
    minikube start --cpus=2 --memory=4096
else
    echo "✅ Minikube is already running"
fi

echo "\n🔍 Checking cluster status..."
kubectl cluster-info

# Check if nginx-pod already exists
if kubectl get pod nginx-pod &> /dev/null; then
    echo "\n⚠️  nginx-pod already exists. Recreating..."
    kubectl delete pod nginx-pod
fi

echo "\n🛠️  Creating nginx Pod..."
kubectl apply -f nginx-pod.yaml

echo "\n⏳ Waiting for Pod to reach Running state..."
kubectl wait --for=condition=Ready pod/nginx-pod --timeout=60s

if [ $? -eq 0 ]; then
    echo "\n✅ Lab setup completed successfully!"
    echo "\n📋 Useful commands:"
    echo "  kubectl get pods           # List Pods"
    echo "  kubectl describe pod nginx-pod  # Pod details"
    echo "  kubectl logs nginx-pod     # View logs"
    echo "  kubectl exec -it nginx-pod -- /bin/bash  # Access container"
    echo "\n📖 Refer to README.md for lab tasks"
else
    echo "\n❌ Failed to set up the lab. Check the logs above."
    exit 1
fi
