// MCP tool: {{TOOL_NAME}}
// {{TOOL_DESCRIPTION}}
//
// Importable function for programmatic composition:
//   import { {{FUNCTION_NAME}} } from './tools/{{TOOL_FILE_NAME}}.js';
//   let result = await {{FUNCTION_NAME}}({{DEFAULT_ARGS}});
import { mcpCall } from '../mcp-client.js';

{{PARAMS_ANNOTATION}}
export async function {{FUNCTION_NAME}}(args) {
    return await mcpCall("{{TOOL_NAME}}", args);
}
