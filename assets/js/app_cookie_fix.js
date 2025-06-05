// Cookie-based fix for WebSocket routing through nginx proxy
// This version sets a cookie to help nginx route WebSocket requests correctly

import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import InputNumberHook from "./input_number_hook"
import WebSocketStatusHook from "./websocket_status_hook"

// Set a cookie to identify this as a components app request
function setBackendCookie() {
  const currentPath = window.location.pathname;
  const isComponentsApp = currentPath.match(/^\/(components|demo|debug|simple_debug|docs|test_ws)/);
  
  if (isComponentsApp) {
    document.cookie = "phoenix_backend=components; path=/; SameSite=Lax";
    console.log("Set backend cookie: components");
  } else {
    document.cookie = "phoenix_backend=pento; path=/; SameSite=Lax";
    console.log("Set backend cookie: pento");
  }
}

// Set the cookie immediately
setBackendCookie();

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let Hooks = {};
Hooks.InputNumber = InputNumberHook;
Hooks.WebSocketStatus = WebSocketStatusHook;

// Add StopReload hook
Hooks.StopReload = {
  mounted() {
    console.log("StopReload hook mounted");
  }
};

// Make Hooks available globally
window.Hooks = Hooks;

// Debug logging
console.log("Initializing LiveSocket with cookie fix...");
console.log("Current location:", window.location.href);

// Force HTTPS detection for proxied environments
const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
const liveUrl = `${protocol}//${window.location.host}/live`;

console.log("LiveSocket URL:", liveUrl);

let liveSocket = new LiveSocket(liveUrl, Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks,
  debug: true
})

// Connection event listeners
liveSocket.on("open", () => console.log("WebSocket opened"));
liveSocket.on("error", (e) => console.error("WebSocket error:", e));
liveSocket.on("close", (e) => console.log("WebSocket closed:", e))

// Progress bar
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// Connect LiveSocket
liveSocket.connect()

// Expose for debugging
window.liveSocket = liveSocket

console.log("App.js loaded with cookie fix.");