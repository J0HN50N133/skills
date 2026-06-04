# {{TOOL_NAME}}

{{TOOL_DESCRIPTION}}

## Parameters

```json
{{PARAMS_SCHEMA_JSON}}
```

## CLI

```bash
# Inspect schema
qjs mcp.js schema {{TOOL_NAME}}

# Call directly
qjs mcp.js call {{TOOL_NAME}} '{{USAGE_EXAMPLE}}'

# Or use the convenience wrapper
qjs {{TOOL_FILE_NAME}}.js '{{USAGE_EXAMPLE}}'
```

## Programmatic

```javascript
import { {{FUNCTION_NAME}} } from './scripts/tools/{{TOOL_FILE_NAME}}.js';

// Call with arguments
let result = await {{FUNCTION_NAME}}({{DEFAULT_ARGS}});

// result.content is an array of MCP content items
for (let item of result.content) {
    if (item.type === 'text') print(item.text);
}
```

{{ADDITIONAL_NOTES}}
