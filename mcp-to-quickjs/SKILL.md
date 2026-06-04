---
name: mcp-to-quickjs
description: Convert MCP (Model Context Protocol) server tools into QuickJS-compatible JavaScript wrapper scripts with dynamic discovery support. Use this skill whenever the user wants to create CLI-accessible scripts from MCP tools, convert an MCP server to standalone scripts, wrap MCP tools for shell scripting or cron jobs, or mentions "MCP to QuickJS", "mcp wrapper", "quickjs mcp". Also trigger when the user wants to dynamically discover and invoke MCP tools from the command line.
---

# MCP to QuickJS

Convert an MCP server's tools into a set of standalone QuickJS (qjs) scripts. The user provides an MCP server URL and auth credentials; you discover all available tools via the MCP JSON-RPC protocol, then generate a portable directory of `.js` wrapper scripts.

The generated directory includes a **universal `mcp.js` entry point** that supports dynamic discovery — `list`, `schema`, and `call` subcommands — plus per-tool convenience wrappers. Tools are discovered on-demand at runtime (no pre-loaded manifest), so the script always reflects the server's current state.

## Workflow

### Step 1: Gather configuration

Ask the user for:

1. **MCP Server URL** — the streamable HTTP endpoint (e.g. `https://api.example.com/mcp`)
2. **Authentication** — one of:
   - Nothing (no auth)
   - A Bearer token (just the token value, e.g. `eyJhbGciOi...` — you will prepend `Bearer `)
   - A full `Authorization` header value (e.g. `Bearer eyJ...` or `Basic dXNlcjpwYXNz`)
   - A custom header name and value (e.g. `X-API-Key: sk-abc123`)
3. **Output directory name** — default to `mcp-quickjs-<hostname>/` in the current directory

**Auth detection logic:**
- If the user provides a value starting with `Bearer `, `Basic `, or another known scheme — use it verbatim as the full `Authorization` header value
- If the user provides a JWT-looking string (starts with `eyJ`) or a simple token — prepend `Bearer `
- If the user provides `HeaderName: value` format (contains `: `) — treat it as a custom header
- Otherwise, wrap it as `Bearer <value>`

Store the detected auth as `AUTH_HEADER` for the config file.

### Step 2: Discover MCP tools

Use `curl` to discover all available tools. Run these commands in sequence:

#### 2a. Initialize the MCP session

```bash
# Omit Authorization header if no auth is needed
curl -i -s -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -H "MCP-Protocol-Version: 2025-11-25" \
  -H "Authorization: <AUTH_HEADER>" \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"mcp-to-quickjs","version":"1.0.0"}}}' \
  "<MCP_URL>"
```

The `-i` flag includes response headers. Parse the JSON body from the output (it follows the headers after a blank line). Look for a `MCP-Session-Id:` header line. If found, extract the session ID value and send an `initialized` notification:

```bash
curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: <AUTH_HEADER>" \
  -H "MCP-Session-Id: <SESSION_ID>" \
  -d '{"jsonrpc":"2.0","method":"notifications/initialized"}' \
  "<MCP_URL>"
```

If no session ID is returned, the endpoint is stateless — skip the initialized notification and set `MCP_SESSION_ID` to empty string.

#### 2b. List tools

```bash
# Omit MCP-Session-Id header if the server is stateless
curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -H "Authorization: <AUTH_HEADER>" \
  -H "MCP-Session-Id: <SESSION_ID>" \
  -d '{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' \
  "<MCP_URL>"
```

Parse the `result.tools` array. Each tool has:
- `name` (required) — unique identifier
- `description` (optional) — human-readable description
- `inputSchema` (required) — JSON Schema for parameters

**Handle pagination**: If the response contains `nextCursor`, repeat the request with `"params":{"cursor":"<nextCursor>"}` until all tools are collected.

**If no tools are returned or the request fails**, tell the user what happened and ask if they want to retry with different credentials or URL.

### Step 3: Generate the output

Create the output directory with this structure:

```
mcp-quickjs-<hostname>/
├── SKILL.md              # Lean overview, tool index, references/ pointer
├── references/            # Progressive disclosure: one .md per tool
│   ├── tool_a.md
│   └── ...
└── scripts/
    ├── run.sh             # Entry wrapper: qjs --std "$@"
    ├── config.js          # URL, auth, session
    ├── mcp-client.js      # Shared runtime: mcpRequest, listTools, helpers
    ├── mcp.js             # CLI dispatcher: list / schema / call
    ├── tools/             # Importable JS functions
    │   ├── tool_a.js      # export async function toolA(args) { ... }
    │   └── ...
    ├── tool_a.js          # CLI convenience: imports tools/tool_a.js
    └── ...
```

For each tool discovered in Step 2b, generate **three files** plus update the index.

First, compute derived names for each tool:
- `TOOL_NAME` — original MCP name (e.g. `get_weather`)
- `TOOL_FILE_NAME` — file-safe: keep underscores/hyphens, replace dots with hyphens (e.g. `get_weather`)
- `FUNCTION_NAME` — camelCase: split by `_` or `-`, capitalize after first word (e.g. `getWeather`)
- `USAGE_EXAMPLE` — realistic JSON string from inputSchema required fields
- `DEFAULT_ARGS` — JS object literal for programmatic example (e.g. `{ location: "Beijing" }`)
- `PARAMS_SCHEMA_JSON` — `JSON.stringify(tool.inputSchema, null, 2)`
- `PARAMS_ANNOTATION` — JSDoc `@param` annotations for each property (type, description, required). If no params, omit this line.

#### 3a. `scripts/config.js`

Template: `assets/templates/config.template.js`. Replace:
- `{{MCP_URL}}` → user-provided URL
- `{{AUTH_HEADER}}` → detected auth value (empty if none)
- `{{MCP_SESSION_ID}}` → session ID from Step 2a (empty if stateless)

#### 3b. `scripts/mcp-client.js`

Copy `assets/mcp-client.js` verbatim. Contains `mcpRequest`, `mcpCall`, `listTools`, `getSchema`, `printToolList`, `printSchema`, `printResult`, `parseArgs`.

#### 3c. `scripts/mcp.js`

Copy `assets/templates/mcp.template.js` verbatim. CLI dispatcher:
```
qjs mcp.js list                     # Dynamic: query server for current tools
qjs mcp.js schema <tool_name>       # Show schema
qjs mcp.js call <tool_name> '{}'    # Call any tool
```

#### 3d. `scripts/tools/<name>.js` (importable function)

Template: `assets/templates/tool-func.template.js`. For each tool, generate:
```javascript
export async function getWeather(args) {
    return await mcpCall("get_weather", args);
}
```

Replace `{{TOOL_NAME}}`, `{{FUNCTION_NAME}}`, `{{TOOL_FILE_NAME}}`, `{{TOOL_DESCRIPTION}}`, `{{DEFAULT_ARGS}}`, `{{PARAMS_ANNOTATION}}`.

The function is pure — it returns the MCP result object. Callers handle display/logic.

#### 3e. `scripts/<name>.js` (CLI convenience wrapper)

Template: `assets/templates/tool-cli.template.js`. For each tool, generate a thin CLI script that imports the function from `tools/` and prints the result.

Replace `{{TOOL_NAME}}`, `{{FUNCTION_NAME}}`, `{{TOOL_FILE_NAME}}`, `{{TOOL_DESCRIPTION}}`, `{{USAGE_EXAMPLE}}`.

#### 3f. `references/<name>.md` (progressive disclosure)

Template: `assets/templates/tool-reference.template.md`. For each tool, generate a detailed reference doc.

Replace `{{TOOL_NAME}}`, `{{TOOL_DESCRIPTION}}`, `{{PARAMS_SCHEMA_JSON}}`, `{{USAGE_EXAMPLE}}`, `{{FUNCTION_NAME}}`, `{{TOOL_FILE_NAME}}`, `{{DEFAULT_ARGS}}`, `{{ADDITIONAL_NOTES}}`.

**`{{ADDITIONAL_NOTES}}`**: If the tool has no required parameters, add `This tool takes no required parameters. Pass \`{}\` or omit arguments.`. If the tool requires auth and the server has it configured, note it. Otherwise leave empty.

#### 3g. `SKILL.md` (output root)

Template: `assets/templates/skill-md.template.md`. This is the **lean** entry point — it must stay under 500 lines even with many tools.

Replace:
- `{{SERVER_HOSTNAME}}` → hostname from URL
- `{{SERVER_URL}}` → full MCP URL
- `{{TOOLS_COUNT}}` → number of tools
- `{{EXAMPLE_FUNCTION}}` → `FUNCTION_NAME` of the first tool
- `{{EXAMPLE_FILE}}` → `TOOL_FILE_NAME` of the first tool
- `{{EXAMPLE_ARGS}}` → `DEFAULT_ARGS` of the first tool
- `{{TOOL_INDEX}}` → a minimal index, one line per tool:
  ```
  - `get_weather` — see `references/get_weather.md`
  - `list_users` — see `references/list_users.md`
  ```
  **Do NOT include descriptions or parameter lists here.** The index is just names + reference file pointers. The AI will read the relevant `references/<name>.md` on demand for details.

### Step 4: Present results

After generation, summarize:
- How many tools were discovered and wrapped
- The output directory path and structure
- **Dynamic discovery**: `cd scripts && qjs mcp.js list` to see all tools
- **Per-tool CLI**: `cd scripts && qjs <tool>.js '{"param": "value"}'`
- **Programmatic composition**: import from `scripts/tools/<tool>.js` to build pipelines
- **Reference docs**: `references/<tool>.md` for each tool's full parameter schema
- Note any tools skipped

**If a tool has no parameters**, the CLI still works with `'{}'`; the function takes an empty object.

## Progressive disclosure design

The generated output uses CodeBuddy's three-level loading:

1. **Metadata** (`SKILL.md` frontmatter): server name, tool count, brief tagline — always in context (~50 words)
2. **SKILL.md body**: usage examples, tool index (names + file pointers) — loaded on trigger (<300 lines)
3. **`references/<name>.md`**: full parameter schemas, detailed examples — read on demand

The AI should **read the relevant `references/<name>.md` before calling a tool**, not rely on the SKILL.md index for parameter details. This keeps the skill lean regardless of how many tools the MCP server exposes.
