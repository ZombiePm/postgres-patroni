# PostgreSQL 17 Patroni Cluster with Synchronous Replication

This repository contains Kubernetes manifests for deploying a highly available PostgreSQL 17 cluster using Patroni with synchronous replication.

## Architecture

- **etcd**: 3-node cluster for distributed configuration storage
- **PostgreSQL**: 2-node Patroni cluster with PostgreSQL 17 and synchronous replication
- **Sync Mode**: Strict synchronous replication (`synchronous_commit: on`)

## Components

1. **etcd cluster** (3 replicas) - etcd v3.5.9
2. **Patroni PostgreSQL cluster** (2 replicas) - PostgreSQL 17
3. **Services**: Headless service for Patroni discovery
4. **ConfigMaps**: Patroni configuration

## Versions

- **PostgreSQL**: 17
- **Spilo**: 17:4.0-p3
- **etcd**: v3.5.9
- **Patroni**: Latest (included in Spilo)

## Deployment

### Option 1: Using Official Spilo Image (if available)

First, verify the image exists:
```bash
docker pull registry.opensource.zalan.do/acid/spilo-15:2.0-p4
```

Then deploy:
```bash
kubectl apply -k .
```

### Option 2: Build Custom Patroni Image

1. Build the image:
```bash
docker build -t postgres-patroni:17 .
```

2. Push to your registry (optional):
```bash
docker tag postgres-patroni:17 your-registry/postgres-patroni:17
docker push your-registry/postgres-patroni:17
```

3. Deploy with custom image:
```bash
kubectl apply -f namespace.yaml
kubectl apply -f etcd-service.yaml
kubectl apply -f etcd-statefulset.yaml
kubectl apply -f patroni-configmap.yaml
kubectl apply -f postgres-service.yaml
kubectl apply -f postgres-statefulset-custom.yaml
```

### Option 3: ArgoCD deployment

Apply the ArgoCD Application manifest:
```bash
kubectl apply -f argocd-application.yaml
```

> **Note**: For custom images, update the `image:` field in `postgres-statefulset-custom.yaml` to point to your registry.
>
> **Compatibility**: This setup is tested with PostgreSQL 17 and Spilo 17:4.0-p3.

## Access

- **PostgreSQL Connection**: `postgres-read.postgres.svc.cluster.local:5432`
- **Direct Primary Access**: `postgres-0.postgres.svc.cluster.local:5432`
- **Patroni REST API**: `postgres-0.postgres.svc.cluster.local:8008`

## Credentials

Default credentials (change in production):
- **Username**: `postgres`
- **Password**: `postgres_password`
- **Replicator User**: `replicator` / `repl_password`

## Monitoring

Check cluster status:

```bash
# Check Patroni status
kubectl exec -it postgres-0 -n postgres -- patronictl list

# Check etcd status
kubectl exec -it etcd-0 -n postgres -- etcdctl endpoint health
```

## Configuration

Key Patroni settings:
- `synchronous_mode: true` - Enable synchronous replication
- `synchronous_mode_strict: true` - Enforce synchronous commits
- `synchronous_standby_names: '*'` - All standbys are synchronous
- `wal_level: replica` - Required for replication

## Failover

Patroni automatically handles failover. To manually trigger failover:

```bash
kubectl exec -it postgres-0 -n postgres -- patronictl switchover
```

## Persistence

- etcd: 1Gi PVC per pod
- PostgreSQL: 10Gi PVC per pod