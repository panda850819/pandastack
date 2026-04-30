---
name: tool-notion
description: Notion pages/databases via notion-cli. Trigger on notion.so URL or Notion task.
---

# notion-cli

CLI tool for Notion workspace management. Requires `NOTION_TOKEN` env var (already configured).

**Rule: use notion-cli for all Notion operations instead of WebFetch or browser tools.**

## Run command

```bash
cd <notion-cli-dir> && uv run notion <command>
```

## Extracting Page ID from URL

Notion URLs contain the page ID as the last 32-char hex string (with dashes inserted as 8-4-4-4-12):

```
https://www.notion.so/<workspace>/Q2-Goal-32c88c20674a80f186efc8d56d099dea
                                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Page ID = 32c88c20674a80f186efc8d56d099dea
```

The CLI accepts both with and without dashes. For `?source=copy_link` or any other query suffix in URLs, ignore everything after `?` — only extract the 32-char hex ID. When the URL contains a slug before the ID (e.g., `Q2-Goal-32c88c20...`), the ID is always the last 32 hex characters.

## Commands

### Search

```bash
# Search workspace
notion search "query"
notion search "query" --type page      # pages only
notion search "query" --type database  # databases only
```

### Page operations

```bash
# Read page content (returns markdown)
notion page get <page_id>

# Create child page
notion page create <parent_id> "Title"
notion page create <parent_id> "Title" --file content.md

# Update page — replace all content (clear first, then write)
notion page update <page_id> --file content.md --clear

# Update page — append new blocks after existing content
notion page update <page_id> --file content.md

# Append to page (at the end)
notion page append <page_id> --file content.md

# Append after a specific block (insert at position)
notion page append <page_id> --file content.md --after <block_id>

# Clear page content
notion page clear <page_id>
```

### Database operations

```bash
# List all databases (returns data source IDs)
notion db list

# Query database — accepts BOTH composite DB ID and data source ID
notion db query <database_id>
notion db query <database_id> --limit 100
```

**ID types:** Notion API 2025-09-03 has two ID types for databases:
- **Composite database ID** — from URLs (e.g., `33788c20-674a-8004-9167-c3bcaae251e9`)
- **Data source ID** — from `db list` output (e.g., `33788c20-674a-819c-8d07-000bb5684fb2`)

Both work interchangeably with `db query`. If one fails, the CLI auto-falls back to the other.

### Task operations

```bash
# Create task in a database
notion task create "Task title" --db <database_id>
notion task create "Task title" --db <database_id> --status "In Progress"

# Update task (--status auto-detects status vs select property type)
notion task update <page_id> --status "Done"
notion task update <page_id> --title "New title"
notion task update <page_id> --status "Done" --db <database_id>
```

### Block operations

```bash
# Get a single block's raw JSON
notion block get <block_id>

# Update a block's text content
notion block update <block_id> --content "New text"
notion block update <block_id> --json '{"paragraph": {"rich_text": [...]}}'

# Delete a block (prompts confirmation, use --force to skip)
notion block delete <block_id>
notion block delete <block_id> --force
```

## Writing content

For `page update`, `page append`, and `page create --file`, write markdown to a temp file first:

```bash
cat > /tmp/notion-content.md << 'EOF'
# Heading
- Bullet point
- Another point

Some paragraph text.
EOF

cd <notion-cli-dir> && uv run notion page update <page_id> --file /tmp/notion-content.md
```

## Usage strategy

### Partial update vs full rewrite

**Default to partial updates** unless the user explicitly requests a full rewrite or the page is empty.

Partial update workflow:
```bash
# 1. List all blocks on a page (use Python API — no CLI block list command)
cd <notion-cli-dir> && PYTHONPATH=src uv run python -c "
from notion_cli import client
blocks = client.get_page_content('<page_id>')
for b in blocks:
    t = b.get('type','')
    text = ''
    rt = b.get(t, {}).get('rich_text', [])
    if rt: text = ''.join([r.get('plain_text','') for r in rt])
    print(f'{b[\"id\"]} {t}: {text[:60]}')
"

# 2. Delete blocks from target heading to next sibling heading
notion block delete <block_id> --force

# 3. Insert new content after the heading (or after last deleted block's predecessor)
notion page append <page_id> --file /tmp/new-section.md --after <heading_block_id>
```

The `--after` flag inserts blocks after a specific block ID, enabling in-place section replacement without dragging in the UI.

Other operations:
- **Append new content:** `page append` after existing content
- **Edit a single block:** `block update` for a specific block
- **Full rewrite:** `page update --file content.md --clear` (only for initial creation or complete overhaul)

### Large content writes
- Pages with 153+ blocks may take 1-2 minutes to update — consider `run_in_background`
- Notion API has incomplete support for markdown tables (`| |` format) — tables may appear empty in `page get` output but render correctly in Notion UI

### Content language
- Follow the language specified by the user — do not default to English

## Python API for advanced operations

When CLI commands are insufficient, use the Python API directly:

```bash
cd <notion-cli-dir> && PYTHONPATH=src uv run python -c "
from notion_cli import client
# client.get_page_content(page_id) — list all child blocks
# client.get_client() — raw Notion SDK client for any API call
# client.get_client().data_sources.query(data_source_id=ds_id) — query by data source ID
# client.get_client().data_sources.retrieve(data_source_id=ds_id) — get DB schema
# client.update_page(page_id, {'Prop': {'select': {'name': 'Value'}}}) — set properties
"
```

### Setting properties by type

```python
# select
{'Status': {'select': {'name': 'Active'}}}
# multi_select
{'Team': {'multi_select': [{'name': 'Product'}, {'name': 'Dev'}]}}
# status (Notion native status type)
{'Status': {'status': {'name': 'In Progress'}}}
# date
{'Due': {'date': {'start': '2026-04-07'}}}
# people (requires Notion user ID, not name)
{'Owner': {'people': [{'id': 'user-uuid-here'}]}}
# relation
{'Projects': {'relation': [{'id': 'page-id-here'}]}}
```

## Known limitations

- `page get` may not display table block content — tables may appear empty in CLI output but render correctly in Notion UI
- Some block types (e.g., `external_object_instance_page`) are not supported by the API
- Large pages may be truncated — use `block get` to read specific sections
- Markdown tables are converted to Notion table blocks on upload, but `page get` may return empty content for them
- No `block list` CLI command — use Python API `client.get_page_content(page_id)` instead
- Linked database views appear as `child_database` blocks in the API — query the original DB for content
- People-type properties require Notion user IDs, not name strings
- `db list` returns data source IDs, not composite database IDs — but `db query` accepts both
- Data source schema structure varies across DBs — some have select/status options directly on the property, others require inferring from row data
