// Enhanced app.js for proxy environments
// This version handles WebSocket connections through nginx proxy correctly

import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import InputNumberHook from "./input_number_hook"
import WebSocketStatusHook from "./websocket_status_hook"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let Hooks = {};
Hooks.InputNumber = InputNumberHook;
Hooks.WebSocketStatus = WebSocketStatusHook;

// Add StopReload hook to prevent page reload during debugging
Hooks.StopReload = {
  mounted() {
    console.log("StopReload hook mounted - preventing auto-reload");
    if (!window._originalReload) {
      window._originalReload = window.location.reload;
      window.location.reload = function() {
        console.log("Reload prevented by StopReload hook");
      };
    }
  },
  destroyed() {
    if (window._originalReload) {
      window.location.reload = window._originalReload;
      delete window._originalReload;
    }
  }
};

// Make Hooks available globally
window.Hooks = Hooks;

// Debug logging
console.log("Initializing LiveSocket with proxy fix...");
console.log("Current location:", window.location.href);

// Detect if we're in a proxied environment
const isProxied = window.location.hostname === "phoenix.biantaishabi.org";
const currentPath = window.location.pathname;

// Determine which backend this page belongs to
const isComponentsApp = currentPath.match(/^\/(components|demo|debug|simple_debug|docs|test_ws)/);

// Construct WebSocket URL based on environment
let liveUrl;
if (isProxied) {
  // In proxied environment, use absolute URL with backend hint
  const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
  const host = window.location.host;
  
  if (isComponentsApp) {
    // For components app pages, use a special path that nginx can route correctly
    liveUrl = `${protocol}//${host}/components/live`;
  } else {
    // For main app pages
    liveUrl = `${protocol}//${host}/live`;
  }
} else {
  // In development or direct access
  const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
  liveUrl = `${protocol}//${window.location.host}/live`;
}

console.log("LiveSocket URL:", liveUrl);
console.log("Is proxied:", isProxied);
console.log("Is components app:", isComponentsApp);

// Add backend hint to connection params
let connectionParams = {
  _csrf_token: csrfToken,
  _backend: isComponentsApp ? "components" : "pento"
};

let liveSocket = new LiveSocket(liveUrl, Socket, {
  longPollFallbackMs: 2500,
  params: connectionParams,
  hooks: Hooks,
  debug: true,
  // Add retry configuration
  reconnectAfterMs: [1000, 2000, 5000, 10000],
  rejoinAfterMs: [1000, 2000, 5000],
  timeout: 20000
})

// Enhanced debugging for connection events
liveSocket.on("open", () => {
  console.log("WebSocket opened successfully");
  console.log("Connection params:", connectionParams);
});

liveSocket.on("error", (e) => {
  console.error("WebSocket error:", e);
  console.error("Error details:", {
    url: liveUrl,
    readyState: liveSocket.socket?.readyState,
    protocol: liveSocket.socket?.protocol
  });
});

liveSocket.on("close", (e) => {
  console.log("WebSocket closed:", e);
  console.log("Close details:", {
    code: e.code,
    reason: e.reason,
    wasClean: e.wasClean
  });
});

// Progress bar configuration
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// Connect LiveSocket
liveSocket.connect()

// Expose for debugging
window.liveSocket = liveSocket

// Add diagnostic function
window.testWebSocketConnection = function() {
  console.log("Testing WebSocket connection...");
  const testUrl = liveUrl.replace(/^wss?:/, 'wss:') + '/websocket?vsn=2.0.0';
  console.log("Test URL:", testUrl);
  
  const ws = new WebSocket(testUrl);
  
  ws.onopen = () => {
    console.log("Test WebSocket opened!");
    // Send Phoenix protocol handshake
    ws.send(JSON.stringify({
      topic: "phoenix",
      event: "heartbeat",
      payload: {},
      ref: "1"
    }));
  };
  
  ws.onmessage = (e) => {
    console.log("Test WebSocket received:", e.data);
  };
  
  ws.onerror = (e) => {
    console.error("Test WebSocket error:", e);
  };
  
  ws.onclose = (e) => {
    console.log("Test WebSocket closed:", {
      code: e.code,
      reason: e.reason,
      wasClean: e.wasClean
    });
  };
  
  return ws;
};

console.log("App.js loaded with proxy fix. Run testWebSocketConnection() to debug.");