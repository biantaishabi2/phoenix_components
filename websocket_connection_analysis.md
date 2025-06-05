# WebSocket Connection Analysis: Manual Test vs LiveView

## Overview
This document analyzes why the manual WebSocket test connects successfully while LiveView fails to establish a connection in the proxied environment.

## Key Differences

### 1. URL Construction

#### Manual Test (Working)
```javascript
const ws = new WebSocket('wss://phoenix.biantaishabi.org/live/websocket?vsn=2.0.0');
```
- Uses **absolute URL** with full domain
- Includes `?vsn=2.0.0` query parameter
- Direct WebSocket connection without abstraction

#### LiveView (Not Working)
```javascript
const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
const liveUrl = `${protocol}//${window.location.host}/live`;
let liveSocket = new LiveSocket(liveUrl, Socket, {...})
```
- Uses **relative URL** based on `window.location.host`
- No query parameters in initial URL
- Phoenix Socket abstraction handles protocol negotiation

### 2. Protocol Handshake

#### Manual Test
```javascript
ws.send(JSON.stringify({
  topic: "phoenix",
  event: "heartbeat",
  payload: {},
  ref: "1"
}));
```
- Sends raw Phoenix protocol message
- Simple heartbeat message
- No channel join or session negotiation

#### LiveView
- Phoenix Socket library handles:
  - Protocol version negotiation
  - Channel joining with topic "lv:phx-xxx"
  - Session authentication with CSRF token
  - Automatic reconnection and heartbeat

### 3. Nginx Routing Issue

The nginx configuration uses `$http_referer` to determine routing:

```nginx
map $http_referer $app_backend {
    ~*/components.*  "components_app";
    default          "pento_app";
}

location /live/websocket {
    proxy_pass http://$app_backend;
    # ...
}
```

**Problem**: WebSocket upgrade requests typically don't include referer headers, causing:
- Initial HTTP request (with referer) → routes correctly
- WebSocket upgrade request (no referer) → routes to wrong backend

### 4. Why Page Keeps Reloading

1. **LiveView Connection Failure Loop**:
   - LiveView tries to connect WebSocket at `/live`
   - Connection fails (wrong backend or protocol mismatch)
   - Falls back to long-polling
   - Long-polling also fails
   - LiveView enters reconnection loop
   - After several failures, triggers page reload

2. **Missing WebSocket Endpoint**:
   - LiveView expects WebSocket at `/live/websocket`
   - But Phoenix constructs the path differently internally
   - The `?vsn=2.0.0` parameter is added by Phoenix.js

## Root Causes

1. **Nginx Routing Logic**: The referer-based routing doesn't work for WebSocket upgrade requests
2. **Protocol Mismatch**: LiveView uses Phoenix Channels protocol, not raw WebSocket
3. **Path Construction**: LiveView's relative URL construction may not match the proxy expectations

## Solutions

### 1. Fix Nginx Configuration
```nginx
# Use request URI instead of referer for WebSocket routing
location ~ ^/components/.*websocket {
    proxy_pass http://components_app;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    # ...
}

location /live/websocket {
    # Route based on the original request path, not referer
    if ($request_uri ~* ^/components/) {
        proxy_pass http://components_app;
    }
    if ($request_uri !~* ^/components/) {
        proxy_pass http://pento_app;
    }
    # ...
}
```

### 2. Use Explicit Backend Headers
Add a custom header in the initial request that persists through the upgrade:
```javascript
let liveSocket = new LiveSocket(liveUrl, Socket, {
  params: {
    _csrf_token: csrfToken,
    _backend: "components" // Add backend hint
  }
})
```

### 3. Direct Domain Access
Configure LiveView to use the absolute URL:
```javascript
const liveUrl = "wss://phoenix.biantaishabi.org/live";
```

## Verification Steps

1. Check WebSocket upgrade headers:
   ```bash
   curl -i -N -H "Connection: Upgrade" -H "Upgrade: websocket" \
        -H "Sec-WebSocket-Version: 13" -H "Sec-WebSocket-Key: x3JJHMbDL1EzLkh9GBhXDw==" \
        https://phoenix.biantaishabi.org/live/websocket
   ```

2. Monitor nginx logs to see which backend receives the request

3. Use browser DevTools Network tab to inspect:
   - Initial HTTP request headers (should have referer)
   - WebSocket upgrade request headers (likely missing referer)

## Conclusion

The manual test works because:
- It uses an absolute URL that bypasses relative path issues
- It sends simple messages without complex protocol negotiation
- It doesn't rely on nginx routing logic

LiveView fails because:
- The nginx routing based on referer doesn't work for WebSocket upgrades
- The relative URL construction may not match the proxy's expectations
- The complex Phoenix Channels protocol requires proper backend routing