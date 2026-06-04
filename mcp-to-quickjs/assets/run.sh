#!/bin/sh
# MCP QuickJS wrapper — ensures qjs runs with --std flag
# Usage: ./run.sh mcp.js list
#        ./run.sh mcp.js schema create_issue
#        ./run.sh mcp.js call create_issue '{"project_id":"123","title":"Fix"}'
#        ./run.sh get_weather.js '{"location":"Beijing"}'
cd "$(dirname "$0")"
exec qjs --std "$@"
