#!/usr/bin/env python3
"""Offline behavior checks for Codex live hook inventory trust."""

import importlib.util
import tempfile
from pathlib import Path


REPO = Path(__file__).resolve().parent.parent
SCRIPT = REPO / "scripts" / "codex-hook-smoke.py"
SPEC = importlib.util.spec_from_file_location("codex_hook_smoke", SCRIPT)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class FakeServer:
    def __init__(self, hooks):
        self.hooks = hooks

    def request(self, method, params):
        assert method == "hooks/list"
        assert len(params["cwds"]) == 1
        return {
            "data": [{
                "warnings": [],
                "errors": [],
                "hooks": self.hooks,
            }],
        }


def hook_rows(root, trust_status):
    manifest = (root / "hooks" / "hooks.json").resolve()
    return [
        {
            "pluginId": "verbs@verbs",
            "eventName": event,
            "matcher": matcher,
            "enabled": True,
            "source": "plugin",
            "sourcePath": str(manifest),
            "command": f"{root}/hooks/test-command",
            "trustStatus": trust_status,
        }
        for event, matcher in sorted(
            MODULE.EXPECTED_EVENTS,
            key=lambda item: (item[0], item[1] or ""),
        )
    ]


def main():
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory) / ".codex" / "plugins" / "cache" / "verbs"
        (root / "hooks").mkdir(parents=True)
        (root / "hooks" / "hooks.json").write_text("{}\n", encoding="utf-8")

        trusted = FakeServer(hook_rows(root, "trusted"))
        MODULE.assert_inventory(trusted, Path(directory), root, require_trusted=True)

        untrusted = FakeServer(hook_rows(root, "untrusted"))
        MODULE.assert_inventory(untrusted, Path(directory), root, require_trusted=False)
        try:
            MODULE.assert_inventory(
                untrusted, Path(directory), root, require_trusted=True)
        except RuntimeError as exc:
            assert "untrusted Verbs hook" in str(exc)
        else:
            raise AssertionError("require_trusted accepted an untrusted hook")

    print("OK: Codex hook inventory trust is enforced only when requested")


if __name__ == "__main__":
    main()
