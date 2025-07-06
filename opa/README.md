## Centralized JWT Validation and OPA Policy Enforcement

In modern SaaS and microservices architectures, it is best practice to centralize authentication and authorization at the API gateway. This project demonstrates how to use Kong Gateway OSS for JWT validation and Open Policy Agent (OPA) for fine-grained, policy-driven authorization.

### How It Works
1. **JWT Validation at the Gateway**
   - Kong's built-in JWT plugin validates the signature, expiry, and claims of incoming JWTs.
   - Only requests with valid tokens are forwarded to your microservices.
   - You can use a shared signing key for all users, or configure Kong Consumers for per-user or per-client keys.
2. **Role/Policy Enforcement with OPA**
   - For advanced authorization (RBAC, ABAC, custom rules), Kong delegates authorization to OPA using the `kong-opa` plugin.
   - OPA receives the request context and JWT claims, evaluates your Rego policies, and returns an allow/deny decision.
   - This enables you to enforce complex access rules (e.g., only users with `agent` or `agency` roles can access `/user/details`).

### Typical Request Flow
1. User logs in and receives a JWT from your authentication service.
2. Client sends the JWT in the `Authorization` header to Kong.
3. Kong validates the JWT using the JWT plugin.
4. Kong (via the kong-opa plugin) sends the request and JWT context to OPA for policy evaluation.
5. OPA evaluates the policy and returns `allow: true` or `false`.
6. Kong allows or blocks the request based on OPA's response.

### Why This Matters
- **Centralized Security:** All authentication and authorization logic is enforced at the gateway, not duplicated in every microservice.
- **Separation of Concerns:** Microservices remain stateless and focused on business logic; Kong and OPA handle security.
- **Flexible, Auditable Policies:** Authorization rules are managed in version-controlled Rego files, making them easy to update and audit.

### Example: Protecting a Route with JWT and OPA
- Enable the JWT plugin on your service or route to require valid tokens.
- Enable the kong-opa plugin to enforce OPA policies for access control.
- Example policy: Only users with `agent` or `agency` roles can access `/user/details`.

This approach provides robust, scalable, and maintainable security for your APIs.

---

## Custom Kong Image & OPA Integration (Advanced Authorization)

This project extends Kong OSS with advanced, centralized authorization using Open Policy Agent (OPA) and the community `kong-opa` plugin. This enables fine-grained, policy-driven access control for your APIs, enforced at the gateway layer.

### How It Works
- **Custom Kong Image:**
  - The `Dockerfile.kong-opa` builds a Kong image with the `kong-opa` plugin installed via LuaRocks.
  - This plugin allows Kong to delegate authorization decisions to an external OPA server.
- **OPA Sidecar:**
  - OPA runs as a sidecar container in the same Docker Compose stack.
  - OPA loads Rego policy files from `opa/policies/` (e.g., `api-authz.rego`).
- **Plugin Communication:**
  - The `kong-opa` plugin is enabled on specific routes/services (e.g., `/user/details`).
  - When a request matches, Kong validates the JWT, then calls OPA (e.g., `http://opa:8181/v1/data/kong/authz/allow`) with request and JWT context.
  - OPA evaluates the policy and returns `allow: true` or `false`.
  - Kong allows or blocks the request based on OPA's decision.

### Example Policy (Rego)
```rego
package kong.authz
allow {
  input.jwt.payload.role == "agent"
}
allow {
  input.jwt.payload.role == "agency"
}
```
This policy allows only users with the `agent` or `agency` role to access the protected route.

### Example Plugin Configuration (Admin API)
```sh
# Enable JWT plugin on the service/route
curl -i -X POST http://localhost:9001/services/<service>/plugins \
  --data "name=jwt"

# Enable kong-opa plugin on the route
curl -i -X POST http://localhost:9001/routes/<route>/plugins \
  --data "name=opa" \
  --data "config.opa_url=http://opa:8181/v1/data/kong/authz/allow" \
  --data "config.input_path=request.jwt"
```

### Benefits
- **Centralized Authorization:** All access control logic is managed in OPA policies, not scattered across microservices.
- **Separation of Concerns:** Kong handles authentication and policy enforcement; OPA handles policy logic; microservices remain stateless and simple.
- **Easy Policy Updates:** Change access rules by editing Rego files, no need to redeploy services.

---