# Kubernetes Deployment for Kong (with Postgres), OPA, and Custom Kong Ingress Controller

This directory contains modular Kubernetes YAML manifests for deploying:
- **Kong Gateway** (custom image with kong-opa plugin, OPA as sidecar)
- **Postgres** database for Kong
- **OPA (Open Policy Agent)** as a sidecar in the Kong Pod
- **Kong Ingress Controller** (custom)
- All required RBAC, secrets, and persistent storage

---

## Structure

- `postgres/` — Postgres DB deployment, service, PVC, and secret
- `kong/` — Kong Gateway deployment (with OPA sidecar), services, Ingress Controller, RBAC, and secrets
- `opa/` — OPA policy ConfigMap (mounted into Kong Pod)
- `namespace.yaml` — Namespace manifest for isolation (apply first)
- `README.md` — This file

---

## Usage

1. **Create Namespace** (if not already present):
   ```sh
   kubectl apply -f namespace.yaml
   ```
2. **Deploy Postgres**:
   ```sh
   kubectl apply -f postgres/
   ```
3. **Deploy OPA Policy ConfigMap**:
   ```sh
   kubectl apply -f opa/
   ```
4. **Deploy Kong (with OPA sidecar) and Ingress Controller**:
   ```sh
   kubectl apply -f kong/
   ```

---

## Notes
- Update image names, secrets, and config as needed for your environment.
- For production, use secure secret management and consider adding NetworkPolicies.
- OPA is run as a sidecar in the Kong Pod for policy enforcement.
- All resources are deployed in the `kong` namespace.
- For advanced configuration, see Kong and OPA documentation.

---

## Example Tree
```
k8s/
  namespace.yaml
  postgres/
    deployment.yaml
    pvc.yaml
    secret.yaml
    service.yaml
  kong/
    admin-service.yaml
    deployment.yaml
    ingress-clusterrole.yaml
    ingress-clusterrolebinding.yaml
    ingress-controller-deployment.yaml
    ingress-serviceaccount.yaml
    license-secret.yaml
    proxy-service.yaml
  opa/
    configmap.yaml
  README.md
```
