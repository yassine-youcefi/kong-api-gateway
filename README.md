# Kong API Gateway with Docker Compose

This project provides a ready-to-use setup for running Kong API Gateway (OSS) with a Postgres database using Docker Compose. It is designed for local development, testing, and learning about API gateway patterns.

## Features

- Kong Gateway (Open Source) with all bundled plugins
- Postgres 16 as Kong's database
- Environment variables managed via `.env` file (see `.env.example` for a template)
- Easy to extend with community GUIs (e.g., Konga)
- Pre-configured for local development

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

### Access

- **Kong Proxy:** http://localhost:8000
- **Kong Admin API:** http://localhost:8001

> Note: Kong Manager (GUI) is only available in Kong Enterprise. For a GUI with Kong OSS, consider adding [Konga](https://pantsel.github.io/konga/).

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
KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl
```

## Useful Commands

- Start: `docker compose up -d`
- Stop: `docker compose down`
- View logs: `docker compose logs -f kong`

## Extending

- To add a GUI, add a Konga service to `docker-compose.yaml`.
- To add plugins, configure them via the Admin API or with declarative config.

## .gitignore

Sensitive files like `.env` and `.rnv` are git-ignored by default. Share only `.env.example` for safe configuration.

## License

This project is provided for educational and development use. See [Kong Gateway OSS License](https://github.com/Kong/kong/blob/master/LICENSE) for details.
