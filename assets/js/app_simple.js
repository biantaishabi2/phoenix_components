// 简化版 app.js - 直接连接正确的 WebSocket
import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

// 直接使用正确的 WebSocket URL
const liveSocket = new LiveSocket("/live", Socket, {
  params: {_csrf_token: csrfToken}
})

// Progress bar
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// Connect
liveSocket.connect()

// Expose for debugging
window.liveSocket = liveSocket

console.log("Simple LiveSocket connected");