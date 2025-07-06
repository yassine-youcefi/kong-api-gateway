<p align="center">
  <img src="https://images.seeklogo.com/logo-png/39/1/kong-logo-png_seeklogo-394595.png" alt="Kong Logo" height="60"/>
  &nbsp;&nbsp;&nbsp;
  <img src="https://www.docker.com/wp-content/uploads/2022/03/Moby-logo.png" alt="Docker Logo" height="60"/>
</p>

# Kong API Gateway with Docker Compose

A modern, local development environment for Kong API Gateway (OSS) with Postgres and Kong Manager OSS UI. Easily manage, secure, and route traffic to your microservices.

---

## Features
- Kong Gateway OSS with all bundled plugins
- Postgres 16 as Kong's database
- Kong Manager OSS (UI) on port 9002
- Environment variables via `.env` (see `.env.example`)
- Custom Docker network for microservices
- Secure, persistent configuration

---

## Table of Contents
- [Getting Started](#getting-started)
- [Accessing Kong Services](#accessing-kong-services)
- [How Kong Proxy Works](#how-kong-proxy-works)
- [Creating Services and Routes](#creating-services-and-routes)
- [Testing Your Integration](#testing-your-integration)
- [Environment Variables](#environment-variables)
- [Useful Commands](#useful-commands)
- [Extending](#extending)
- [License](#license)

---

## Getting Started

### Prerequisites
- [Docker](https://www.docker.com/products/docker-desktop)
- [Docker Compose](https://docs.docker.com/compose/)

### Setup
1. Clone this repository:
   ```sh
   git clone <your-repo-url>
   cd kong-api-gateway
   ```
2. Copy the example environment file and edit as needed:
   ```sh
   cp .env.example .env
   # Edit .env to set your credentials and settings
   ```
3. Start the stack:
   ```sh
   docker compose up -d
   ```

---

## Accessing Kong Services
- **Kong Proxy:** http://localhost:8888
- **Kong Admin API:** http://localhost:9001
- **Kong Manager OSS (UI):** http://localhost:9002

Kong Manager OSS is enabled by default on port 9002 with basic authentication.

---

## How Kong Proxy Works
When a user sends a request to `http://localhost:8888/<route-path>`, the following happens:
1. Kong receives the request on port 8888 (host), mapped to port 8000 inside the Kong container.
2. Kong matches the request to a configured **Route**.
3. Kong forwards the request to the associated **Service** (your microservice), using the internal Docker network.
4. Kong returns the response from your service to the client.

**Note:**
- Kong does not expose your microservice directly to the host. All traffic goes through Kong for routing, security, and plugins.
- By default, Kong removes the route path prefix before proxying (`strip_path: true`). Set `strip_path: false` if your service expects the full path.

---

## Creating Services and Routes
You can create services and routes via Kong Manager OSS (UI) or the Admin API.

### Using Kong Manager OSS (UI)
1. Go to http://localhost:9002 and log in.
2. **Create a Service:**
   - Name: e.g. `django-api-gateway`
   - Host: `<your-service-container-name>` (e.g. `django-api-gateway-microservice`)
   - Port: `<your-service-port>` (e.g. `8000`)
   - Protocol: `http`
3. **Create a Route:**
   - Name: e.g. `user-details`
   - Paths: `/user/details/`
   - Methods: `GET` (or as needed)
   - (Optional) Set `strip_path: false` if your service expects the full path.
   - Link the route to your service.

### Using the Admin API
Example (replace values as needed):
```sh
# Create a service
curl -i -X POST http://localhost:9001/services \
  --data 'name=django-api-gateway' \
  --data 'url=http://django-api-gateway-microservice:8000'

# Create a route
curl -i -X POST http://localhost:9001/services/django-api-gateway/routes \
  --data 'paths[]=/user/details/' \
  --data 'methods[]=GET' \
  --data 'strip_path=false'
```

---

## Testing Your Integration
To test your microservice through Kong, always send requests to the Kong Proxy port (default: **8888**), not directly to your service.

**Example:**
```sh
curl -i http://localhost:8888/user/details/ -H "Authorization: Bearer <your_token>"
```
- Replace `/user/details/` and the header as needed.
- If your route requires headers or authentication, add them to your request.
- You can also use Postman or your browser for GET requests.

**Do not use your service's internal Docker port directly. Always go through Kong's proxy port.**

---

## Environment Variables
All configuration is managed in the `.env` file. See `.env.example` for a template. Example:
```
POSTGRES_USER=kong
POSTGRES_DB=kong
POSTGRES_PASSWORD=changeme
KONG_DATABASE=postgres
KONG_PG_HOST=kong-database
KONG_PG_USER=kong
KONG_PG_PASSWORD=changeme
KONG_PROXY_ACCESS_LOG=/dev/stdout
KONG_ADMIN_ACCESS_LOG=/dev/stdout
KONG_PROXY_ERROR_LOG=/dev/stderr
KONG_ADMIN_ERROR_LOG=/dev/stderr
KONG_ADMIN_LISTEN=0.0.0.0:9001, 0.0.0.0:9444 ssl
KONG_ADMIN_GUI_LISTEN=0.0.0.0:9002
KONG_ADMIN_GUI_AUTH=basic
KONG_ADMIN_GUI_SESSION_CONF={"secret":"changeme","cookie_secure":false}
KONG_ADMIN_GUI_SESSION_SECRET=changeme
```

---

## Useful Commands
- Start: `docker compose up -d`
- Stop: `docker compose down`
- View logs: `docker compose logs -f kong`

---

## Extending
- To add plugins, configure them via the Admin API, Kong Manager, or with declarative config.

---

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

## Adding a New API Endpoint with Role-Based Access (Developer Guide)

When you want to expose a new API endpoint through Kong and restrict it to a specific role (e.g., `account_manager`), follow these steps:

### 1. Create the Service and Route in Kong
- Use Kong Manager UI or the Admin API to add your backend service and define the route (e.g., `/account/manage`).

### 2. Enable the JWT Plugin
- Attach the JWT plugin to the service or route to require JWT authentication.

### 3. Enable the kong-opa Plugin
- Attach the kong-opa plugin to the route or service.
- Configure it to call your OPA endpoint (e.g., `http://opa:8181/v1/data/kong/authz/allow`).

### 4. Update the OPA Policy (Rego)
- Edit the main Rego file (e.g., `api-authz.rego`) to add a rule for the new endpoint and role.
- Example for allowing only the `account_manager` role to access `/account/manage`:
  ```rego
  package kong.authz

  default allow = false

  allow {
    input.request.path == "/account/manage"
    some role
    input.parsed_jwt.payload.roles[_] == role
    role == "account_manager"
  }
  ```
- You do **not** need a separate Rego file for each endpoint; manage all rules in one file.
- You do **not** need to predefine all roles—just reference them in your policy as needed.

### 5. No Need to Rebuild Kong for New Routes
- Adding new services, routes, or updating OPA policies does **not** require rebuilding or redeploying the Kong container.
- Only rebuild Kong if you change the Kong image itself (e.g., add new plugins).

### Summary Table
| Action                                 | Rebuild Kong? | Edit Rego? | Predefine Roles? | New Rego File? |
|-----------------------------------------|:-------------:|:----------:|:----------------:|:--------------:|
| Add service/route/plugin                |      No       |   Maybe*   |       No         |      No        |
| Add/change access rule for a route/role |      No       |   Yes      |       No         |      No        |
| Add new plugin to Kong image            |     Yes       |    No      |       No         |      No        |

\*Edit Rego if you want to enforce new access rules for the new route.

---

## Note: Community Plugins and Kong Manager UI

- Community plugins like `kong-opa` (OPA integration) are not bundled with Kong OSS by default and may not appear in the Kong Manager UI, even if installed in your custom image.
- **Kong Manager UI only lists plugins that are marked as "visible" and "supported" in its metadata.**
- Community plugins often do not include the UI components or metadata needed for the Manager UI.
- **How to enable and configure the kong-opa plugin:**
  - Use the Admin API (curl, httpie, Postman, etc.), not the UI.
  - Example:
    ```sh
    curl -i -X POST http://localhost:9001/services/<service-name>/plugins \
      --data "name=opa" \
      --data "config.opa_url=http://opa:8181/v1/data/kong/authz/allow" \
      --data "config.input_path=parsed_jwt"
    ```
  - You can check if the plugin is installed with:
    ```sh
    curl http://localhost:9001/plugins/enabled
    ```
  - The plugin will work as expected if installed and configured via the API, even if it does not show up in the UI.

---

# 🚀 Managing Kong and OPA Configuration at Scale (Best Practices)

> **For large teams and production environments, follow these proven methods to ensure safe, scalable, and auditable API gateway management.**

## 1. Centralized, Version-Controlled Configuration
- **Store all Kong and OPA config as code** in a central Git repository.
- **Developers propose changes via pull/merge requests**—all changes are reviewed by the API/platform/security team before merging.
- **Restrict write access to production config** to a small, trusted group.

## 2. Kong in DB-Backed Mode (with Postgres)
- **Run Kong with a Postgres database** for dynamic, scalable configuration.
- **Apply changes using Kong’s Admin API** (never direct DB edits).
- **Back up the Kong Postgres DB** regularly, especially before major changes.

## 3. Automated CI/CD Pipeline
- **Test and validate** new routes/services and OPA policies in dev.
- **Export config changes** (e.g., with [decK](https://github.com/kong/deck)) or use scripts for reproducibility.
- **Promote changes through environments** (dev → staging → prod) using CI/CD automation.
- **Sync Rego files to OPA** and reload policies as part of the pipeline.

## 4. Why This Approach?
- 🛡️ **Prevents config drift and accidental misconfiguration**
- 📝 **Ensures all changes are auditable and reviewed**
- 🔄 **Enables safe, automated promotion of changes**
- 📈 **Scales for large teams and complex systems**

## 5. Recommended Tools
- [decK](https://github.com/kong/deck): Declarative Kong config management (export/import/apply/diff)
- [OPA CLI](https://www.openpolicyagent.org/docs/latest/#running-opa): Policy validation and testing
- **CI/CD platforms:** GitHub Actions, GitLab CI, Jenkins, etc.

---

