# PostgreSQL Patroni Cluster with Synchronous Replication

This repository contains Kubernetes manifests for deploying a highly available PostgreSQL cluster using Patroni with synchronous replication.

## Architecture

- **etcd**: 3-node cluster for distributed configuration storage
- **PostgreSQL**: 2-node Patroni cluster with synchronous replication
- **Sync Mode**: Strict synchronous replication (`synchronous_commit: on`)

## Components

1. **etcd cluster** (3 replicas)
2. **Patroni PostgreSQL cluster** (2 replicas)
3. **Services**: Headless service for Patroni discovery
4. **ConfigMaps**: Patroni configuration

## Deployment

### Option 1: Direct kubectl deployment

```bash
kubectl apply -k .
```

### Option 2: ArgoCD deployment

Apply the ArgoCD Application manifest:

```bash
kubectl apply -f argocd-application.yaml
```

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