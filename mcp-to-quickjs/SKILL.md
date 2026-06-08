---
name: mcp-to-quickjs
description: Convert MCP (Model Context Protocol) server tools into QuickJS-compatible JavaScript wrapper scripts with dynamic discovery support. Use this skill whenever the user wants to create CLI-accessible scripts from MCP tools, convert an MCP server to standalone scripts, wrap MCP tools for shell scripting or cron jobs, or mentions "MCP to QuickJS", "mcp wrapper", "quickjs mcp". Also trigger when the user wants to dynamically discover and invoke MCP tools from the command line.
---

# MCP to QuickJS

Convert an MCP server's tools into a set of standalone QuickJS (qjs) scripts. The user provides an MCP server URL; you discover all available tools via the MCP JSON-RPC protocol, then generate a portable directory of `.js` wrapper scripts.

The generated directory includes a **universal `mcp.js` entry point** that supports dynamic discovery — `list`, `schema`, and `call` subcommands — plus per-tool convenience wrappers. Tools are discovered on-demand at runtime (no pre-loaded manifest), so the script always reflects the server's current state.

**Authentication is handled automatically.** If the MCP server uses OAuth2 (returns 401 + `WWW-Authenticate`), the skill walks through the standard MCP Authorization flow (OAuth2.1 + PKCE + dynamic client registration) and generates a reusable `auth-login.js` tool.

## Workflow

### Step 1: Gather configuration

Ask the user for:

1. **MCP Server URL** — the streamable HTTP endpoint (e.g. `https://api.example.com/mcp`)
2. **Output directory name** — default to `mcp-quickjs-<hostname>/` in the current directory
3. **Additional custom headers** (optional) — any extra headers the server requires, e.g. `X-Tools-Set: my_tools`. Format: `Header-Name: value`, one per line only if there are headers beyond auth.

**Do NOT ask the user for auth credentials upfront.** Instead, proceed to Step 1a to probe the server.

### Step 1a: Probe the server and auto-detect authentication

First, probe the MCP server **without any auth** to discover its requirements:

```bash
curl -i -s -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -H "MCP-Protocol-Version: 2025-11-25" \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-11-25","capabilities":{},"clientInfo":{"name":"mcp-to-quickjs","version":"1.0.0"}}}' \
  "<MCP_URL>"
```

**If the server responds with 200 + JSON body**, no auth is needed. Skip to Step 2a.

**If the server responds with 401 + `WWW-Authenticate` header**, the server uses OAuth2. Follow the OAuth2 auto-authentication flow below.

#### OAuth2 Auto-Authentication Flow

This is the standard MCP Authorization protocol (OAuth2.1 + PKCE + dynamic client registration). The process:

```
MCP Client ──GET /mcp──▶ MCP Server
              ◀── 401 + WWW-Authenticate: Bearer resource_metadata="https://iam.../..."

Step A: Discover auth server from resource_metadata
Step B: Dynamically register a public client (RFC 7591)
Step C: Execute PKCE authorization_code flow
Step D: Save access_token + refresh_token to config.json
```

##### A. Discover the OAuth2 authorization server

Parse the `WWW-Authenticate` header from the 401 response. Extract the `resource_metadata` URL and fetch it:

```bash
curl -s "<RESOURCE_METADATA_URL>" | python3 -m json.tool
```

Record:
- `AUTH_SERVER` = `authorization_servers[0]` (e.g. `https://iam.it.woa.com/oauth2/`)
- `SCOPE` = typically `"openid profile offline offline_access"`

##### B. Dynamically register a public client

For CLI tools, do NOT use pre-registered client secrets. Register a public client with `token_endpoint_auth_method: "none"`:

```bash
curl -s -X POST "<AUTH_SERVER>/register" \
  -H "Content-Type: application/json" \
  -d '{
    "client_name": "<dir_name>-mcp-quickjs",
    "grant_types": ["authorization_code", "refresh_token"],
    "response_types": ["code"],
    "redirect_uris": ["http://localhost:8899/callback"],
    "token_endpoint_auth_method": "none",
    "application_type": "native"
  }'
```

Record `CLIENT_ID` from the response. This client_id will be used for the PKCE flow.

##### C. Execute PKCE authorization_code flow interactively

Guide the user through the OAuth2 PKCE flow. The script `assets/auth-login.js` handles this automatically. Generate the authorization URL:

1. Generate `code_verifier` (48 random bytes, base64url)
2. Compute `code_challenge = base64url(sha256(code_verifier))`
3. Generate random `state` (anti-CSRF)
4. Build the authorization URL:

```
<AUTH_SERVER>/authorize?
  response_type=code
  client_id=<CLIENT_ID>
  code_challenge=<challenge>
  code_challenge_method=S256
  resource=<MCP_URL>
  redirect_uri=http://localhost:8899/callback
  state=<state>
  scope=openid profile offline offline_access
```

**Critical PKCE implementation details:**
- Use `printf '%s' "$VERIFIER" | openssl dgst -sha256 -binary | openssl base64 | tr -d '=\n' | tr '/+' '_-'` for challenge computation. Do NOT use `echo -n` — it mangles binary data with special characters.
- Save `{state, code_verifier, client_id, created_at}` to a session file so it persists between tool invocations. Load and reuse the session on repeat runs — overwriting it causes `code_verifier`/`code_challenge` mismatch → `invalid_grant`.

Present the authorization URL to the user. They open it in their browser, complete authentication, and the browser redirects them to `http://localhost:8899/callback?code=XXXXX&state=YYYYY`.

Ask the user to paste the full redirect URL from their browser address bar. Parse the `code` parameter from it. Validate the `state` matches the saved session.

##### D. Exchange code for tokens

```bash
curl -s -X POST "<AUTH_SERVER>/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -H "Authorization: Basic $(printf '%s' '<CLIENT_ID>:' | openssl base64)" \
  -d "client_id=<CLIENT_ID>&grant_type=authorization_code&code=<CODE>&code_verifier=<VERIFIER>&redirect_uri=http%3A%2F%2Flocalhost%3A8899%2Fcallback"
```

The response contains:
```json
{
  "access_token": "...",    // 7 days typical
  "refresh_token": "...",   // 30 days typical, one-time use
  "expires_in": 604800,
  "token_type": "bearer"
}
```

Save to `config.json`:
```json
{
  "AUTH_HEADER": "Bearer <access_token>",
  "REFRESH_TOKEN": "<refresh_token>",
  "EXPIRES_AT": <timestamp>
}
```

This token is now used for Step 2 tool discovery.

##### E. Generate auth-login.js for future re-authentication

After successful authentication, the generated output will include `auth-login.js` (from `assets/auth-login.js` template) for the user to re-authenticate when tokens expire. This tool encapsulates the entire OAuth2 PKCE flow: `--new` for new sessions, `--url` for code exchange, `--refresh` for token refresh, `--status` to check expiry.

Set `AUTH_MODE = "oauth2"` in the conversion state.

### Step 2: Discover MCP tools

Use `curl` to discover all available tools. The `AUTH_HEADER` is now available from the OAuth2 flow (Step 1a-D) or from user-provided credentials.

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
├── .gitignore             # Ignores config.json (always generated for OAuth2)
├── config.json.example    # Template: copy to config.json, run auth-login.js to fill
├── references/            # Progressive disclosure: one .md per tool
│   ├── tool_a.md
│   └── ...
└── scripts/
    ├── run.sh             # Entry wrapper: qjs --std "$@"
    ├── config.js          # URL, auth (reads config.json), session
    ├── mcp-client.js      # Shared runtime: mcpRequest, listTools, helpers
    ├── mcp.js             # CLI: list / schema / call <name> '<json>'
    ├── auth-login.js      # [OAuth2] PKCE login tool for re-authentication
    └── tools/             # Importable JS functions
        ├── tool_a.js      # export async function toolA(args) { ... }
        └── ...
```

`mcp.js` is the **only** CLI entry point — no per-tool wrappers. Each tool exists as a function in `tools/` for programmatic composition, plus a reference in `references/` for on-demand schema lookup.

For each tool discovered in Step 2b, generate **two files** plus update the index.

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
- `{{AUTH_READER}}` → **DO NOT insert the literal token** — generate the runtime auth reading code based on the auth mode:
  - **OAuth2 mode** (AUTH_MODE = "oauth2"): Config file method — reads `config.json` (populated by `auth-login.js`). The `AUTH_HEADER` field includes the `Bearer ` prefix.
  - **Env var mode** (user chose env var): `std.getenv("MCP_AUTH_TOKEN") || ""`
  - **No auth**: `""`
- `{{MCP_SESSION_ID}}` → session ID from Step 2a (empty if stateless)
- `{{CUSTOM_HEADERS}}` → JS array entries for any additional headers, e.g. `["X-Tools-Set", "my_tools"]`. Each entry on its own line with trailing comma. If no custom headers, leave empty.

**CRITICAL: Never hardcode tokens in source files.**

##### Config file pattern (used for OAuth2 mode)

```javascript
let __authHeader = "";
try {
    const f = std.open("../config.json", "r");
    __authHeader = JSON.parse(f.readAsString()).AUTH_HEADER || "";
    f.close();
} catch (e) {}
export const AUTH_HEADER = __authHeader;
```

The `config.json` format (created by `auth-login.js`, not manually):
```json
{
  "AUTH_HEADER": "Bearer eyJ...",
  "REFRESH_TOKEN": "ory_rt_...",
  "EXPIRES_AT": 1781253648713
}
```

##### Env var pattern (user-chosen, non-OAuth2)
```javascript
export const AUTH_HEADER = std.getenv("MCP_AUTH_TOKEN") || "";
```

#### 3b. `scripts/run.sh`

Copy `assets/run.sh` verbatim and make it executable (`chmod +x`). This wraps `qjs --std "$@"` so users don't need to remember the `--std` flag.

Usage: `./run.sh mcp.js list`, `./run.sh mcp.js call get_weather '{"location":"Beijing"}'`

#### 3c. `scripts/mcp-client.js`

Copy `assets/mcp-client.js` verbatim. Contains `mcpRequest`, `mcpCall`, `listTools`, `getSchema`, `printToolList`, `printSchema`, `printResult`, `parseArgs`. Supports `CUSTOM_HEADERS` from config for server-specific headers.

#### 3d. `scripts/mcp.js`

Copy `assets/templates/mcp.template.js` verbatim. CLI dispatcher:
```
./run.sh mcp.js list                     # Dynamic: query server for current tools
./run.sh mcp.js schema <tool_name>       # Show schema
./run.sh mcp.js call <tool_name> '{}'    # Call any tool
```

#### 3e. `scripts/tools/<name>.js` (importable function)

Template: `assets/templates/tool-func.template.js`. For each tool, generate:
```javascript
export async function getWeather(args) {
    return await mcpCall("get_weather", args);
}
```

Replace `{{TOOL_NAME}}`, `{{FUNCTION_NAME}}`, `{{TOOL_FILE_NAME}}`, `{{TOOL_DESCRIPTION}}`, `{{DEFAULT_ARGS}}`, `{{PARAMS_ANNOTATION}}`.

The function is pure — it returns the MCP result object. Callers handle display/logic.

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
- `{{SERVER_DESCRIPTION}}` → a one-line summary of what the server platform does and what users can accomplish with it. **Describe the platform, not the skill.** For example: `Get current weather, forecasts, and alerts for any location worldwide.` or `Manage tasks, bugs, and feature requests across projects.` Do NOT write "provides CLI access" or "wraps MCP tools" — those describe the skill's internals, not the server's purpose.
- `{{EXAMPLE_FUNCTION}}` → `FUNCTION_NAME` of the first tool
- `{{EXAMPLE_FILE}}` → `TOOL_FILE_NAME` of the first tool
- `{{EXAMPLE_ARGS}}` → `DEFAULT_ARGS` of the first tool
- `{{TOOL_INDEX}}` → a minimal index, one line per tool:
  ```
  - `get_weather` — see `references/get_weather.md`
  - `list_users` — see `references/list_users.md`
  ```
  **Do NOT include descriptions or parameter lists here.** The index is just names + reference file pointers. The AI will read the relevant `references/<name>.md` on demand for details.

#### 3h. `scripts/auth-login.js` (only if OAuth2 mode)

Copy `assets/auth-login.js` and replace placeholders:
- `{{AUTH_SERVER}}` → authorization server URL discovered in Step 1a-A
- `{{MCP_URL}}` → user-provided MCP server URL
- `{{DIR_NAME}}` → output directory basename (e.g. `mcp-quickjs-example` or user-chosen name)
- `{{SCOPE}}` → scopes from OIDC discovery (usually `"openid profile offline offline_access"`)

This tool is the **user's entry point for re-authentication**. It encapsulates:
- Dynamic client registration (`/oauth2/register`)
- PKCE generation (`code_verifier` + `code_challenge` via SHA-256)
- Interactive authorization URL generation
- Callback URL parsing and code exchange
- Token storage to `config.json`
- Token refresh support (`--refresh`)
- Session reuse (prevents `code_verifier`/`code_challenge` mismatch on repeat runs)

CLI interface:
```
./run.sh auth-login.js                    生成/复用授权链接
./run.sh auth-login.js --new              强制创建新授权会话
./run.sh auth-login.js --url '<回调URL>'   粘贴回调URL，自动交换token
./run.sh auth-login.js --refresh          刷新 access_token
./run.sh auth-login.js --status           查看 token 状态
```

#### 3i. `.gitignore` and `config.json.example` (only in OAuth2 or config file mode)

**`.gitignore`** — prevents the auth config from being committed:
```
config.json
```

**`config.json.example`** — template for users to copy and fill in (for OAuth2 mode, `auth-login.js` handles this automatically):
```json
{
  "AUTH_HEADER": "Bearer your_token_here",
  "REFRESH_TOKEN": "",
  "EXPIRES_AT": 0
}
```

### Step 4: Present results

After generation, summarize:
- How many tools were discovered and wrapped
- The output directory path and structure
- **Authentication**: If OAuth2 was used, note that `config.json` already contains a valid token and `auth-login.js` is available for re-authentication
- **CLI**: `cd scripts && ./run.sh mcp.js list` to discover; `./run.sh mcp.js call <name> '{}'` to invoke
- **Programmatic composition**: import from `scripts/tools/<tool>.js` to build pipelines
- **Reference docs**: `references/<tool>.md` for each tool's full parameter schema
- Note any tools skipped

**If a tool has no parameters**, pass `'{}'` or omit the json arg.

## Progressive disclosure design

The generated output uses CodeBuddy's three-level loading:

1. **Metadata** (`SKILL.md` frontmatter): server name, tool count, brief tagline — always in context (~50 words)
2. **SKILL.md body**: usage examples, tool index (names + file pointers) — loaded on trigger (<300 lines)
3. **`references/<name>.md`**: full parameter schemas, detailed examples — read on demand

The AI should **read the relevant `references/<name>.md` before calling a tool**, not rely on the SKILL.md index for parameter details. This keeps the skill lean regardless of how many tools the MCP server exposes.
