// MCP Universal Client
// Usage:
//   qjs mcp.js list                          List all available tools
//   qjs mcp.js schema <tool_name>            Show a tool's parameters
//   qjs mcp.js call <tool_name> '<json>'     Call a tool with JSON args
import { listTools, getSchema, mcpCall, printToolList, printSchema, printResult, parseArgs } from './mcp-client.js';

let cmd = scriptArgs[1];
let toolName = scriptArgs[2];
let jsonArgs = scriptArgs[3];

if (cmd === "list") {
    let tools = await listTools();
    if (tools) printToolList(tools);
} else if (cmd === "schema") {
    if (!toolName) {
        print("Usage: qjs mcp.js schema <tool_name>");
    } else {
        let tool = await getSchema(toolName);
        printSchema(tool);
    }
} else if (cmd === "call") {
    if (!toolName) {
        print("Usage: qjs mcp.js call <tool_name> '<json_args>'");
    } else {
        let args = parseArgs(jsonArgs);
        let result = await mcpCall(toolName, args);
        printResult(result);
    }
} else {
    print("Usage:");
    print("  qjs mcp.js list                     List all available tools");
    print("  qjs mcp.js schema <tool_name>       Show tool parameters");
    print("  qjs mcp.js call <tool_name> '{}'    Call a tool with JSON args");
}
