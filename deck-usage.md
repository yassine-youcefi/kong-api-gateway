# decK Kong Configuration Management

This guide describes how to use [decK](https://github.com/kong/deck) to manage Kong configuration as code when running Kong in database-backed (Postgres) mode.

## 1. Install decK

- Download from https://github.com/kong/deck/releases or use Homebrew:
  ```sh
  brew install deck
  # or
  curl -sL https://github.com/kong/deck/releases/latest/download/deck_$(uname -s)_$(uname -m).tar.gz | tar xz -C /usr/local/bin deck
  ```

## 2. Export Kong Configuration

- Export the current Kong config (services, routes, plugins, etc.) to a YAML file:
  ```sh
  deck dump --kong-addr http://localhost:9001 > kong.yaml
  ```
- Commit `kong.yaml` to your version control system (e.g., Git).

## 3. Diff Kong Configuration

- Compare your local config file with the current Kong state:
  ```sh
  deck diff --kong-addr http://localhost:9001 -s kong.yaml
  ```
- This shows what will change if you apply your config.

## 4. Sync Kong Configuration

- Apply your config file to Kong (syncs DB state to match your YAML):
  ```sh
  deck sync --kong-addr http://localhost:9001 -s kong.yaml
  ```
- Use this in CI/CD to promote changes from dev → staging → prod.

## 5. Rollback

- To rollback, simply sync a previous version of `kong.yaml`.

## 6. Best Practices
- Always review diffs before syncing to production.
- Protect `kong.yaml` in version control (code review, PRs).
- Use decK in your CI/CD pipeline for automated, auditable Kong config management.

---

For more, see the [decK documentation](https://github.com/kong/deck).
