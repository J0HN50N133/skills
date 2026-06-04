// MCP tool wrapper: {{TOOL_NAME}}
// {{TOOL_DESCRIPTION}}
//
// CLI usage: qjs {{TOOL_FILE_NAME}}.js '{{USAGE_EXAMPLE}}'
import { {{FUNCTION_NAME}} } from './tools/{{TOOL_FILE_NAME}}.js';
import { parseArgs, printResult } from './mcp-client.js';

let args = parseArgs(scriptArgs[1]);
let result = await {{FUNCTION_NAME}}(args);
printResult(result);
