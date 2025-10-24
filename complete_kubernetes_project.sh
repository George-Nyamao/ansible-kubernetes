#!/bin/bash

cd ~/ansible-projects/ansible-kubernetes

# Create site.yml
cat > site.yml << 'EOF'
---
- name: "Kubernetes Cluster Setup - Prerequisites"
  hosts: kubernetes
  become: yes
  
  pre_tasks:
    - name: Display deployment information
      debug:
        msg:
          - "=========================================="
          - "Kubernetes Cluster Setup Starting"
          - "=========================================="
          - "Target: {{ inventory_hostname }}"
          - "IP: {{ ansible_default_ipv4.address }}"
          - "=========================================="
      tags: always

  roles:
    - role: kubernetes-prereq
      tags: prereq

- name: "Kubernetes Master Configuration"
  hosts: k8s_master
  become: yes
  
  roles:
    - role: kubernetes-master
      tags: master

  post_tasks:
    - name: Display master setup information
      debug:
        msg:
          - "=========================================="
          - "✅ Kubernetes Master Configured!"
          - "=========================================="
          - "Master Node: {{ ansible_default_ipv4.address }}"
          - ""
          - "Next: Run worker node configuration"
          - "=========================================="
      tags: always

- name: "Kubernetes Worker Configuration"
  hosts: k8s_workers
  become: yes
  serial: 1
  
  pre_tasks:
    - name: Wait for join command to be available
      wait_for:
        path: /tmp/kubeadm_join.sh
        timeout: 300
      delegate_to: "{{ groups['k8s_master'][0] }}"
      run_once: true
      tags: workers

  roles:
    - role: kubernetes-worker
      tags: workers

  post_tasks:
    - name: Display worker setup information
      debug:
        msg:
          - "=========================================="
          - "✅ Worker Node {{ inventory_hostname }} Joined!"
          - "=========================================="
      tags: always

- name: "Kubernetes Add-ons Installation"
  hosts: k8s_master
  
  roles:
    - role: kubernetes-addons
      tags: addons

  post_tasks:
    - name: Display cluster status
      shell: kubectl get nodes
      environment:
        KUBECONFIG: /home/{{ ansible_user }}/.kube/config
      register: cluster_status
      changed_when: false
      tags: always

    - name: Display cluster information
      debug:
        msg:
          - "=========================================="
          - "✅ Kubernetes Cluster Ready!"
          - "=========================================="
          - "{{ cluster_status.stdout }}"
          - ""
          - "To access the cluster:"
          - "export KUBECONFIG=$(pwd)/kubeconfig"
          - ""
          - "Dashboard Access:"
          - "kubectl proxy"
          - "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
          - "=========================================="
      tags: always
EOF

# Create Makefile
cat > Makefile << 'EOF'
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
EOF

# Create README.md with single quotes
cat > README.md << 'EOF'
# Ansible Kubernetes Cluster Automation

Complete Kubernetes cluster automation using Ansible - from installation to production-ready setup.

## Features

- ✅ Automated Kubernetes cluster initialization
- ✅ Master and worker node configuration
- ✅ Container runtime (containerd) setup
- ✅ Flannel network plugin deployment
- ✅ Metrics server installation
- ✅ Kubernetes Dashboard
- ✅ ETCD backup automation
- ✅ RBAC configuration
- ✅ Production-ready security settings

## Project Structure

'''
.
├── ansible.cfg
├── site.yml
├── Makefile
├── inventory/
│   └── hosts
├── group_vars/
│   ├── all.yml
│   ├── k8s_master.yml
│   └── k8s_workers.yml
└── roles/
    ├── kubernetes-prereq/
    ├── kubernetes-master/
    ├── kubernetes-worker/
    ├── kubernetes-addons/
    └── kubernetes-apps/
'''

## Quick Start

### 1. Clone Repository

'''bash
git clone https://github.com/yourusername/ansible-kubernetes.git
cd ansible-kubernetes
'''

### 2. Configure Inventory

Edit `inventory/hosts`:

'''ini
[k8s_master]
k8s-master ansible_host=192.168.1.60 ansible_user=ubuntu

[k8s_workers]
k8s-worker1 ansible_host=192.168.1.61 ansible_user=ubuntu
k8s-worker2 ansible_host=192.168.1.62 ansible_user=ubuntu
'''

### 3. Deploy Cluster

'''bash
make deploy
'''

### 4. Access Cluster

'''bash
export KUBECONFIG=$(pwd)/kubeconfig
kubectl get nodes
'''

## Usage

### Check Cluster Status

'''bash
make status
# or
export KUBECONFIG=$(pwd)/kubeconfig
kubectl get nodes -o wide
kubectl get pods --all-namespaces
'''

### Access Kubernetes Dashboard

'''bash
make dashboard
# Open: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
'''

### View Cluster Logs

'''bash
make logs
# or
export KUBECONFIG=$(pwd)/kubeconfig
kubectl logs -f pod-name -n namespace
'''

### Deploy an Application

'''bash
export KUBECONFIG=$(pwd)/kubeconfig
kubectl apply -f deployment.yaml
'''

## Kubernetes Cluster Components

### Master Node Components
- API Server: REST API for cluster management
- Scheduler: Assigns pods to nodes
- Controller Manager: Runs controller processes
- ETCD: Cluster data store

### Worker Node Components
- Kubelet: Node agent
- Container Runtime: containerd
- Kube Proxy: Network proxy

### Add-ons
- Flannel: Network plugin
- Metrics Server: Resource monitoring
- Dashboard: Web UI
- CoreDNS: DNS service

## Configuration

### Cluster Settings

Edit `group_vars/all.yml`:

'''yaml
k8s_version: "1.28.0"
k8s_pod_network_cidr: "10.244.0.0/16"
k8s_service_cidr: "10.96.0.0/12"
'''

### Enable/Disable Add-ons

'''yaml
metrics_server_enabled: true
dashboard_enabled: true
'''

## Deployment Examples

### Nginx Deployment

'''bash
export KUBECONFIG=$(pwd)/kubeconfig
kubectl create deployment nginx --image=nginx:latest
kubectl scale deployment nginx --replicas=3
'''

### Service Exposure

'''bash
kubectl expose deployment nginx --port=80 --type=LoadBalancer
'''

### ConfigMap and Secrets

'''bash
kubectl create configmap app-config --from-literal=key=value
kubectl create secret generic app-secret --from-literal=password=secret
'''

### StatefulSet

'''yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mysql
spec:
  serviceName: mysql
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: "password"
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
  volumeClaimTemplates:
  - metadata:
      name: mysql-storage
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
'''

## Networking

### ClusterIP Service (Internal)

'''yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-service
spec:
  type: ClusterIP
  selector:
    app: backend
  ports:
  - port: 80
    targetPort: 8080
'''

### NodePort Service

'''yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
spec:
  type: NodePort
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 3000
    nodePort: 30000
'''

### LoadBalancer Service

'''yaml
apiVersion: v1
kind: Service
metadata:
  name: api-service
spec:
  type: LoadBalancer
  selector:
    app: api
  ports:
  - port: 80
    targetPort: 8080
'''

## Storage

### PersistentVolume

'''yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-data
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/data"
'''

### PersistentVolumeClaim

'''yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-data
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
'''

## Troubleshooting

### Node Not Ready

'''bash
export KUBECONFIG=$(pwd)/kubeconfig
kubectl describe node node-name
kubectl get pods -n kube-system
'''

### Pod Not Running

'''bash
kubectl describe pod pod-name -n namespace
kubectl logs pod-name -n namespace
'''

### Network Issues

'''bash
kubectl get svc --all-namespaces
kubectl get endpoints
kubectl run -it --image=busybox test -- sh
'''

### Cluster Recovery

'''bash
# Check ETCD status
kubectl get pods -n kube-system

# Restore from backup
ansible-playbook restore-etcd.yml
'''

## Backup and Recovery

### Manual Backup

'''bash
ansible k8s_master -m shell -a "/usr/local/bin/etcd_backup.sh" --become
'''

### Automated Backups

Backups run daily at 2 AM. Configure in `group_vars/all.yml`.

### Restore Cluster

'''bash
# Stop API server
kubectl --kubeconfig=/etc/kubernetes/admin.conf patch node master --patch '{"spec":{"unschedulable":true}}'

# Restore ETCD from backup
ETCDCTL_API=3 etcdctl snapshot restore snapshot.db --data-dir=/var/lib/etcd-restored

# Restart cluster
systemctl restart kubelet
'''

## Best Practices

1. **Resource Requests/Limits**: Always set for pods
2. **Health Checks**: Implement liveness and readiness probes
3. **Rolling Updates**: Use deployments for zero-downtime updates
4. **Security**: Use RBAC and network policies
5. **Monitoring**: Implement Prometheus and Grafana
6. **Logging**: Centralize logs with ELK or similar
7. **Backups**: Regular ETCD snapshots
8. **Updates**: Plan and test upgrades
9. **Resource Quotas**: Limit namespace resources
10. **Pod Disruption Budgets**: Ensure availability during disruptions

## Production Considerations

- High availability (multi-master setup)
- etcd cluster redundancy
- Load balancer for API server
- Network policies for security
- Pod security policies
- Resource quotas per namespace
- Network monitoring
- Cluster autoscaling
- Persistent volume backups
- Regular security audits

## Requirements

- Ansible 2.9+
- Ubuntu 20.04/22.04 LTS
- Minimum 2 CPU per node
- Minimum 2GB RAM per node
- 20GB disk space
- Network connectivity between nodes

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create feature branch
3. Make changes
4. Test thoroughly
5. Submit pull request

## License

MIT License

## Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/ansible-kubernetes/issues)
- **Kubernetes Docs**: [kubernetes.io](https://kubernetes.io/docs/)

## Changelog

### v1.0.0 (2024-01-XX)
- Initial release
- Multi-node cluster setup
- Add-ons installation
- ETCD backup automation

## Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- LinkedIn: [Your Profile](https://linkedin.com/in/yourprofile)

---

⭐ **Star this repository if you find it helpful!**
EOF

# Convert single quotes to backticks
sed -i "s/'''/\`\`\`/g" README.md

echo ""
echo "=========================================="
echo "Project 4 Complete!"
echo "=========================================="
echo ""
echo "Files created:"
echo "  - site.yml"
echo "  - Makefile"
echo "  - README.md"
echo ""
echo "To finish setup, run:"
echo "  cd ~/ansible-projects/ansible-kubernetes"
echo "  git init"
echo "  git add ."
echo "  git commit -m 'Initial Kubernetes cluster automation'"
echo "  git remote add origin https://github.com/yourusername/ansible-kubernetes.git"
echo "  git push -u origin main"
echo "=========================================="

