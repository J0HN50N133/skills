---
name: {{SERVER_HOSTNAME}}-tools
description: {{SERVER_DESCRIPTION}} Use when you need to interact with {{SERVER_HOSTNAME}}. To get details on a specific tool, read references/<tool_name>.md.
---

# {{SERVER_HOSTNAME}} MCP Tools

{{TOOLS_COUNT}} tools wrapped from `{{SERVER_URL}}`. Each tool is available as:
- An **importable JS function** in `scripts/tools/<name>.js` — for programmatic composition
- A **CLI call** via `./run.sh mcp.js call <name> '{}'` — for ad-hoc invocation
- A **detailed reference** in `references/<name>.md` — read on demand for parameter schemas

## Quick start

All scripts are in `scripts/`. First `cd scripts/`.

### Discovery

```bash
qjs mcp.js list              # See all tools and descriptions
qjs mcp.js schema <name>     # Inspect a tool's input schema
qjs mcp.js call <name> '{}'  # Call any tool with JSON args
```

### Programmatic composition

Import tool functions to build pipelines and workflows:

```javascript
import { {{EXAMPLE_FUNCTION}} } from './tools/{{EXAMPLE_FILE}}.js';

let result = await {{EXAMPLE_FUNCTION}}({{EXAMPLE_ARGS}});
// result.content[0].text contains the response
```

### Per-tool references

Each tool has a detailed doc in `references/<tool_name>.md` with:
- Full parameter schema
- CLI and programmatic usage examples
- Notes on authentication requirements

**Read the relevant reference file before calling a tool** — this ensures you use correct parameter names, types, and required fields.

## Tool index

{{TOOL_INDEX}}
