// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
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
    // Store original reload function
    if (!window._originalReload) {
      window._originalReload = window.location.reload;
      // Override reload to prevent it
      window.location.reload = function() {
        console.log("Reload prevented by StopReload hook");
      };
    }
  },
  destroyed() {
    // Restore original reload function
    if (window._originalReload) {
      window.location.reload = window._originalReload;
      delete window._originalReload;
    }
  }
};

// Make Hooks available globally for inline scripts
window.Hooks = Hooks;

// Debug: Log connection attempt
console.log("Initializing LiveSocket...");
console.log("Current location:", window.location.href);

// Force HTTPS detection for proxied environments
const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
const currentPath = window.location.pathname;

// 根据当前路径决定WebSocket URL
let liveUrl;
if (currentPath.match(/^\/(components|demo|debug|simple_debug|test_ws|minimal|ws_test|docs)/)) {
  // 对于components_app的页面，使用带路径前缀的WebSocket URL
  // 这样nginx可以根据路径正确路由
  liveUrl = `${protocol}//${window.location.host}${currentPath}/live`;
} else {
  // 对于主应用的页面，使用默认路径
  liveUrl = `${protocol}//${window.location.host}/live`;
}

console.log("LiveSocket URL:", liveUrl);
console.log("Current protocol:", window.location.protocol);
console.log("Current host:", window.location.host);
console.log("Current path:", currentPath);

let liveSocket = new LiveSocket(liveUrl, Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks,
  // Add debug logging
  debug: true
})

// Add connection event listeners for debugging
liveSocket.on("open", () => console.log("WebSocket opened"));
liveSocket.on("error", (e) => console.error("WebSocket error:", e));
liveSocket.on("close", (e) => console.log("WebSocket closed:", e))

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

