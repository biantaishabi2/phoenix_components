#!/bin/bash

# WebSocket Connection Diagnostic Script

echo "=== Phoenix WebSocket Connection Diagnostics ==="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROXY_URL="phoenix.biantaishabi.org"
LOCAL_PENTO="localhost:4000"
LOCAL_COMPONENTS="localhost:4010"

echo "Testing WebSocket endpoints..."
echo ""

# Function to test WebSocket connection
test_websocket() {
    local url=$1
    local name=$2
    
    echo -n "Testing $name: "
    
    # Use curl to test WebSocket upgrade
    response=$(curl -s -o /dev/null -w "%{http_code}" \
        -H "Connection: Upgrade" \
        -H "Upgrade: websocket" \
        -H "Sec-WebSocket-Version: 13" \
        -H "Sec-WebSocket-Key: x3JJHMbDL1EzLkh9GBhXDw==" \
        "$url" 2>/dev/null)
    
    if [ "$response" = "101" ]; then
        echo -e "${GREEN}✓ Success (101 Switching Protocols)${NC}"
        return 0
    elif [ "$response" = "426" ]; then
        echo -e "${YELLOW}⚠ WebSocket upgrade required (426)${NC}"
        return 1
    elif [ "$response" = "404" ]; then
        echo -e "${RED}✗ Not Found (404)${NC}"
        return 1
    else
        echo -e "${RED}✗ Failed (HTTP $response)${NC}"
        return 1
    fi
}

# Test proxy endpoints
echo "1. Testing Proxy Endpoints (https://$PROXY_URL)"
echo "   ----------------------------------------"
test_websocket "https://$PROXY_URL/live/websocket?vsn=2.0.0" "LiveView WebSocket"
test_websocket "https://$PROXY_URL/socket/websocket?vsn=2.0.0" "Phoenix Channel WebSocket"
test_websocket "https://$PROXY_URL/components/live/websocket?vsn=2.0.0" "Components LiveView"
echo ""

# Test local endpoints
echo "2. Testing Local Pento Endpoints (http://$LOCAL_PENTO)"
echo "   ----------------------------------------"
test_websocket "http://$LOCAL_PENTO/live/websocket?vsn=2.0.0" "LiveView WebSocket"
test_websocket "http://$LOCAL_PENTO/socket/websocket?vsn=2.0.0" "Phoenix Channel WebSocket"
echo ""

echo "3. Testing Local Components Endpoints (http://$LOCAL_COMPONENTS)"
echo "   ----------------------------------------"
test_websocket "http://$LOCAL_COMPONENTS/live/websocket?vsn=2.0.0" "LiveView WebSocket"
test_websocket "http://$LOCAL_COMPONENTS/socket/websocket?vsn=2.0.0" "Phoenix Channel WebSocket"
echo ""

# Test with different headers
echo "4. Testing Proxy with Referer Headers"
echo "   ----------------------------------------"
echo -n "Testing with /components referer: "
response=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Connection: Upgrade" \
    -H "Upgrade: websocket" \
    -H "Sec-WebSocket-Version: 13" \
    -H "Sec-WebSocket-Key: x3JJHMbDL1EzLkh9GBhXDw==" \
    -H "Referer: https://$PROXY_URL/components/table" \
    "https://$PROXY_URL/live/websocket?vsn=2.0.0" 2>/dev/null)

if [ "$response" = "101" ]; then
    echo -e "${GREEN}✓ Success${NC}"
else
    echo -e "${RED}✗ Failed (HTTP $response)${NC}"
fi
echo ""

# Check nginx logs if available
echo "5. Checking Nginx Logs (if accessible)"
echo "   ----------------------------------------"
if [ -f /var/log/nginx/phoenix_access.log ]; then
    echo "Recent WebSocket requests:"
    grep -i websocket /var/log/nginx/phoenix_access.log | tail -5
else
    echo "Nginx logs not accessible. Run with sudo or check manually."
fi
echo ""

# Provide diagnosis
echo "=== Diagnosis ==="
echo ""
echo "Common issues:"
echo "1. Nginx referer-based routing doesn't work for WebSocket upgrades"
echo "2. Missing or incorrect proxy headers"
echo "3. Phoenix endpoint configuration mismatch"
echo "4. SSL/TLS termination issues"
echo ""

echo "Recommended solutions:"
echo "1. Use the fixed nginx configuration (nginx-phoenix-proxy-fixed.conf)"
echo "2. Implement URI-based routing for WebSocket connections"
echo "3. Add explicit WebSocket endpoint matching in nginx"
echo "4. Consider using sticky sessions for WebSocket connections"
echo ""

# Create a simple HTML test page
cat > websocket_test.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>WebSocket Connection Test</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .test { margin: 10px 0; padding: 10px; border: 1px solid #ddd; }
        .success { background-color: #d4edda; }
        .error { background-color: #f8d7da; }
        pre { background: #f4f4f4; padding: 10px; overflow-x: auto; }
    </style>
</head>
<body>
    <h1>WebSocket Connection Test</h1>
    <button onclick="runTests()">Run All Tests</button>
    <div id="results"></div>

    <script>
        const tests = [
            { url: 'wss://phoenix.biantaishabi.org/live/websocket?vsn=2.0.0', name: 'Proxy LiveView' },
            { url: 'ws://localhost:4000/live/websocket?vsn=2.0.0', name: 'Local Pento' },
            { url: 'ws://localhost:4010/live/websocket?vsn=2.0.0', name: 'Local Components' }
        ];

        function testWebSocket(url, name) {
            return new Promise((resolve) => {
                const startTime = Date.now();
                const result = { name, url, success: false, message: '', duration: 0 };
                
                try {
                    const ws = new WebSocket(url);
                    
                    ws.onopen = () => {
                        result.success = true;
                        result.message = 'Connected successfully';
                        result.duration = Date.now() - startTime;
                        ws.close();
                        resolve(result);
                    };
                    
                    ws.onerror = (e) => {
                        result.message = 'Connection error';
                        result.duration = Date.now() - startTime;
                        resolve(result);
                    };
                    
                    ws.onclose = (e) => {
                        if (!result.success) {
                            result.message = `Connection closed: ${e.code} - ${e.reason || 'No reason'}`;
                            result.duration = Date.now() - startTime;
                            resolve(result);
                        }
                    };
                    
                    setTimeout(() => {
                        if (ws.readyState !== WebSocket.OPEN) {
                            result.message = 'Connection timeout';
                            result.duration = Date.now() - startTime;
                            ws.close();
                            resolve(result);
                        }
                    }, 5000);
                    
                } catch (e) {
                    result.message = `Exception: ${e.message}`;
                    result.duration = Date.now() - startTime;
                    resolve(result);
                }
            });
        }

        async function runTests() {
            const resultsDiv = document.getElementById('results');
            resultsDiv.innerHTML = '<h2>Test Results</h2>';
            
            for (const test of tests) {
                const result = await testWebSocket(test.url, test.name);
                
                const div = document.createElement('div');
                div.className = `test ${result.success ? 'success' : 'error'}`;
                div.innerHTML = `
                    <h3>${result.name}</h3>
                    <p><strong>URL:</strong> ${result.url}</p>
                    <p><strong>Status:</strong> ${result.success ? '✓ Success' : '✗ Failed'}</p>
                    <p><strong>Message:</strong> ${result.message}</p>
                    <p><strong>Duration:</strong> ${result.duration}ms</p>
                `;
                resultsDiv.appendChild(div);
            }
        }
    </script>
</body>
</html>
EOF

echo "Created websocket_test.html - Open this file in a browser to test WebSocket connections interactively."
echo ""

# Make script executable
chmod +x "$0"