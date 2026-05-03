# JSONL Session Timeline

Pandastack session timeline telemetry appends one JSON object per event to a daily JSONL file:

```text
~/.pdctx/audit/timeline-YYYY-MM-DD.jsonl
```

The intended events are:

- `session_start`
- `skill_invoke`
- `tool_use`
- `session_end`

Each event includes timestamp, runtime, event name, session id, active pdctx context, and current working directory. Runtime hooks may add event-specific fields such as model, process id, skill name, tool name, duration, or exit code. The timeline does not collect prompt content, tool arguments, command output, or file contents. The only potentially identifying operational fields are `cwd`, `context`, and `session_id`.

To opt out for a shell session:

```bash
export PDCTX_TIMELINE_DISABLED=1
```

Sample analysis:

```bash
jq -r '.skill // empty' ~/.pdctx/audit/timeline-*.jsonl | sort | uniq -c | sort -rn
```
