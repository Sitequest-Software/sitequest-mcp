#!/usr/bin/env bash
# Test the Sitequest MCP server with curl
# Replace YOUR_API_KEY with a real key from https://hosting.site.quest/en/dashboard/settings/api

API_KEY="YOUR_API_KEY"
ENDPOINT="https://hosting.site.quest/mcp"

echo "=== Initialize ==="
curl -s -X POST "$ENDPOINT" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {
      "protocolVersion": "2025-03-26",
      "capabilities": {},
      "clientInfo": { "name": "curl-test", "version": "1.0" }
    }
  }' | jq .

echo ""
echo "=== List Tools ==="
curl -s -X POST "$ENDPOINT" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{"jsonrpc": "2.0", "id": 2, "method": "tools/list"}' | jq .

echo ""
echo "=== Call list_vms ==="
curl -s -X POST "$ENDPOINT" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{
    "jsonrpc": "2.0",
    "id": 3,
    "method": "tools/call",
    "params": {
      "name": "list_vms",
      "arguments": {}
    }
  }' | jq .
