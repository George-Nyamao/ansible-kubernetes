# Ansible Kubernetes Cluster Automation

Complete Kubernetes cluster automation using Ansible - from installation to production-ready setup.

- ✅ Automated Kubernetes cluster initialization
- ✅ Master and worker node configuration
- ✅ Container runtime (containerd) setup
- ✅ Flannel network plugin deployment
- ✅ Metrics server installation
- ✅ Kubernetes Dashboard
- ✅ ETCD backup automation
- ✅ RBAC configuration
- ✅ Production-ready security settings

## 🔗 Connect With Me

[![GitHub](https://img.shields.io/badge/GitHub-George--Nyamao-181717?style=for-the-badge&logo=github)](https://github.com/George-Nyamao)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-George_Nyamao-0A66C2?style=for-the-badge&logo=linkedin)](https://www.linkedin.com/in/george-nyamao-842137218/)
[![Email](https://img.shields.io/badge/Email-gmnyamao@hotmail.com-D14836?style=for-the-badge&logo=gmail)](mailto:gmnyamao@hotmail.com)



## Project Structure



[![GitHub](https://img.shields.io/badge/GitHub-George--Nyamao-181717?style=for-the-badge&logo=github)](https://github.com/George-Nyamao)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-George_Nyamao-0A66C2?style=for-the-badge&logo=linkedin)](https://www.linkedin.com/in/george-nyamao-842137218/)
[![Email](https://img.shields.io/badge/Email-gmnyamao@hotmail.com-D14836?style=for-the-badge&logo=gmail)](mailto:gmnyamao@hotmail.com)
```
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
```

## Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/George-Nyamao/ansible-kubernetes.git
cd ansible-kubernetes
```

### 2. Configure Inventory

Edit `inventory/hosts`:

```ini
[k8s_master]
k8s-master ansible_host=192.168.1.60 ansible_user=ubuntu

[k8s_workers]
k8s-worker1 ansible_host=192.168.1.61 ansible_user=ubuntu
k8s-worker2 ansible_host=192.168.1.62 ansible_user=ubuntu
```

### 3. Deploy Cluster

```bash
make deploy
```

### 4. Access Cluster

```bash
export KUBECONFIG=$(pwd)/kubeconfig
kubectl get nodes
```

## Usage

### Check Cluster Status

```bash
make status
# or
export KUBECONFIG=$(pwd)/kubeconfig
kubectl get nodes -o wide
kubectl get pods --all-namespaces
```

### Access Kubernetes Dashboard

```bash
make dashboard
# Open: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

### View Cluster Logs

```bash
make logs
# or
export KUBECONFIG=$(pwd)/kubeconfig
kubectl logs -f pod-name -n namespace
```

### Deploy an Application

```bash
export KUBECONFIG=$(pwd)/kubeconfig
kubectl apply -f deployment.yaml
```

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

```yaml
k8s_version: "1.28.0"
k8s_pod_network_cidr: "10.244.0.0/16"
k8s_service_cidr: "10.96.0.0/12"
```

### Enable/Disable Add-ons

```yaml
metrics_server_enabled: true
dashboard_enabled: true
```

## Deployment Examples

### Nginx Deployment

```bash
export KUBECONFIG=$(pwd)/kubeconfig
kubectl create deployment nginx --image=nginx:latest
kubectl scale deployment nginx --replicas=3
```

### Service Exposure

```bash
kubectl expose deployment nginx --port=80 --type=LoadBalancer
```

### ConfigMap and Secrets

```bash
kubectl create configmap app-config --from-literal=key=value
kubectl create secret generic app-secret --from-literal=password=secret
```

### StatefulSet

```yaml
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
```

## Networking

### ClusterIP Service (Internal)

```yaml
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
```

### NodePort Service

```yaml
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
```

### LoadBalancer Service

```yaml
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
```

## Storage

### PersistentVolume

```yaml
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
```

### PersistentVolumeClaim

```yaml
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
```

## Troubleshooting

### Node Not Ready

```bash
export KUBECONFIG=$(pwd)/kubeconfig
kubectl describe node node-name
kubectl get pods -n kube-system
```

### Pod Not Running

```bash
kubectl describe pod pod-name -n namespace
kubectl logs pod-name -n namespace
```

### Network Issues

```bash
kubectl get svc --all-namespaces
kubectl get endpoints
kubectl run -it --image=busybox test -- sh
```

### Cluster Recovery

```bash
# Check ETCD status
kubectl get pods -n kube-system

# Restore from backup
ansible-playbook restore-etcd.yml
```

## Backup and Recovery

### Manual Backup

```bash
ansible k8s_master -m shell -a "/usr/local/bin/etcd_backup.sh" --become
```

### Automated Backups

Backups run daily at 2 AM. Configure in `group_vars/all.yml`.

### Restore Cluster

```bash
# Stop API server
kubectl --kubeconfig=/etc/kubernetes/admin.conf patch node master --patch '{"spec":{"unschedulable":true}}'

# Restore ETCD from backup
ETCDCTL_API=3 etcdctl snapshot restore snapshot.db --data-dir=/var/lib/etcd-restored

# Restart cluster
systemctl restart kubelet
```

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
[![GitHub Issues](https://img.shields.io/github/issues/George-Nyamao/ansible-kubernetes)](https://github.com/George-Nyamao/ansible-kubernetes/issues)
[![GitHub Discussions](https://img.shields.io/badge/GitHub-Discussions-181717?style=flat&logo=github)](https://github.com/George-Nyamao/ansible-kubernetes/discussions)

- **Issues**: [GitHub Issues](https://github.com/George-Nyamao/ansible-kubernetes/issues)
- **Documentation**: See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed guide
- **Kubernetes Docs**: [kubernetes.io](https://kubernetes.io/docs/)

### v1.0.0 (2025-10-23)
- Initial release
- Multi-node cluster setup
- Add-ons installation
- ETCD backup automation

## Acknowledgments

- Kubernetes community
- Ansible community
- Contributors

## Author

**George Nyamao**
- GitHub: [@George-Nyamao](https://github.com/George-Nyamao)
- LinkedIn: [George Nyamao](https://www.linkedin.com/in/george-nyamao-842137218/)
- Email: gmnyamao@hotmail.com

---

## Related Projects

- [Ansible LAMP Stack](https://github.com/George-Nyamao/ansible-lamp-stack)
- [Ansible Docker Automation](https://github.com/George-Nyamao/ansible-docker-automation)
- [Ansible Jenkins CI/CD](https://github.com/George-Nyamao/ansible-jenkins-cicd)

⭐ **Star this repository if you find it helpful!**
