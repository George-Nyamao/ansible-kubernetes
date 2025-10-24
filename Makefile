.PHONY: help install check deploy clean test dashboard logs status

help:
	@echo "Kubernetes Cluster Automation"
	@echo "=============================="
	@echo "Available commands:"
	@echo "  make install    - Install dependencies"
	@echo "  make check      - Run syntax check"
	@echo "  make deploy     - Deploy Kubernetes cluster"
	@echo "  make test       - Test cluster deployment"
	@echo "  make status     - Show cluster status"
	@echo "  make dashboard  - Access Kubernetes dashboard"
	@echo "  make logs       - Show cluster logs"
	@echo "  make clean      - Clean temporary files"

install:
	@echo "Installing dependencies..."
	pip3 install kubernetes

check:
	@echo "Checking syntax..."
	ansible-playbook site.yml --syntax-check
	@echo "Running dry-run..."
	ansible-playbook site.yml --check

deploy:
	@echo "Deploying Kubernetes cluster..."
	ansible-playbook site.yml

test:
	@echo "Testing cluster deployment..."
	export KUBECONFIG=$(pwd)/kubeconfig
	kubectl get nodes
	kubectl get pods --all-namespaces

status:
	@echo "Cluster Status:"
	export KUBECONFIG=$(pwd)/kubeconfig
	kubectl get nodes -o wide
	kubectl get pods --all-namespaces

dashboard:
	@echo "Starting Kubernetes dashboard..."
	@echo "Open: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
	export KUBECONFIG=$(pwd)/kubeconfig
	kubectl proxy

logs:
	@echo "Showing cluster logs..."
	export KUBECONFIG=$(pwd)/kubeconfig
	kubectl logs -f deployment/coredns -n kube-system

clean:
	@echo "Cleaning up..."
	find . -name "*.retry" -delete
	find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.pyc" -delete
