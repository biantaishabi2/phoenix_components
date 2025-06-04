// WebSocket status hook for debugging
const WebSocketStatusHook = {
  mounted() {
    console.log("WebSocket Status Hook mounted");
    this.updateStatus();
    
    // Monitor connection changes
    this.handleEvent("phx:connected", () => this.updateStatus());
    this.handleEvent("phx:disconnected", () => this.updateStatus());
  },
  
  updateStatus() {
    const socket = window.liveSocket;
    if (socket) {
      console.log("LiveSocket found:", socket);
      console.log("Is connected:", socket.isConnected());
      console.log("Transport:", socket.transport);
      console.log("Endpoint URL:", socket.endpointURL());
    } else {
      console.log("LiveSocket not found!");
    }
  }
};

export default WebSocketStatusHook;