---
name: {{SERVER_HOSTNAME}}-tools
description: QuickJS wrappers for {{TOOLS_COUNT}} MCP tools from {{SERVER_HOSTNAME}}. These scripts provide CLI access and importable JS functions for MCP tools at {{SERVER_URL}}. Supports dynamic discovery (mcp.js list/schema/call) and programmatic composition. To get details on a specific tool, read references/<tool_name>.md.
---

# {{SERVER_HOSTNAME}} MCP Tools

{{TOOLS_COUNT}} tools wrapped from `{{SERVER_URL}}`. Each tool is available as:
- A **JS function** in `scripts/tools/<name>.js` — importable for programmatic composition
- A **CLI convenience wrapper** at `scripts/<name>.js` — call directly with JSON args
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
