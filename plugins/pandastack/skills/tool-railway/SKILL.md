---
name: tool-railway
description: |
  Railway deployments/logs/envs via railway CLI.

  Trigger on: railway.com URL, 'deploy to railway', 'railway logs'.
  Skip when: non-Railway infrastructure.
user-invocable: false
---

# Railway CLI

Manage Railway deployments, services, and infrastructure from the terminal.

## Doctor / Health Check

```bash
railway --version                    # CLI installed
railway whoami                       # Auth status
railway status                       # Current linked project/environment
```

## Project Linking

Railway CLI is project-scoped. Link before running commands:

```bash
railway link --project <project-id> --environment <env-id>
```

Extract IDs from Railway dashboard URLs:
- `railway.com/project/<projectId>?environmentId=<envId>`

## Service Discovery

```bash
railway service status --all         # List all services with deploy status
```

Status values: `SUCCESS`, `CRASHED`, `FAILED`, `BUILDING`, `DEPLOYING`, `REMOVED`

## Logs

```bash
railway logs --service <name>        # Deploy/runtime logs (default)
railway logs --service <name> --build # Build logs only
railway logs --service <name> --deployment <id>  # Specific deployment
```

## Variables

```bash
railway variable --service <name>               # List all vars
railway variable --service <name> | grep -i KEY  # Search specific var
railway variable set KEY=value --service <name>  # Set a variable
railway variable delete KEY --service <name>     # Delete a variable
```

**Safety**: Setting variables on production services triggers a redeploy. Confirm with user before `variable set` on production.

## Deployments

```bash
railway deployment list --service <name>         # List recent deployments
railway redeploy --service <name>                # Redeploy latest
railway restart --service <name>                 # Restart without rebuild
railway down --service <name>                    # Remove latest deployment
```

## Common Crash Diagnosis Flow

1. `railway service status --all` — identify which services are unhealthy
2. `railway logs --service <name>` — read runtime logs for error messages
3. `railway logs --service <name> --build` — check if build failed
4. `railway variable --service <name>` — verify env vars are set (especially DB/Redis URLs)
5. Fix variables or code, then `railway redeploy --service <name>`

## Common Issues

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| CRASHED + "env var not set" | Missing reference variable | `railway variable set` or re-link reference in dashboard |
| FAILED + build logs OK | Container exits immediately | Check runtime logs, often missing env var or port binding |
| CRASHED loop (repeated restarts) | App throws on startup | Fix the error, redeploy |
| Build fails at prisma generate | Missing DATABASE_URL at build time | Add as build-time variable |

## Reference Variables

Railway services can reference variables from other services (e.g., Redis, Postgres). When a plugin is redeployed or recreated, references can break, leaving consumer services with empty values.

To check: compare `railway variable --service Redis` (source) vs `railway variable --service <consumer>` (should match).

## Project: natural-joy (Yei Sentinel)

Project ID: `82a9947b-4927-49d9-8a7a-59875d117756`
Environment: production (`5c8d241b-e780-43ab-857b-df45110b9d34`)

Services:
- **api** — Express API (`@yei-sentinel/api`)
- **engine** — Processing engine (`@yei-sentinel/engine`)
- **log-router** — Log routing (`engine:router`)
- **alert-router** — Alert routing
- **ingestor-sei** — Sei chain ingestion
- **Postgres** — PostgreSQL database
- **Redis** — Redis cache/queue

Internal domains: `<service>.railway.internal`

## MCP Server

Railway CLI has a built-in MCP server:
```bash
railway mcp                          # Start MCP server (stdio)
claude mcp add railway -- railway mcp  # Add to Claude Code
```

Requires active `railway login` session. Provides read/write access to Railway API through Claude Code.
