defmodule ShopUxPhoenixWeb.TestController do
  use ShopUxPhoenixWeb, :controller

  def index(conn, _params) do
    html(conn, """
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8"/>
      <title>WebSocket Test</title>
    </head>
    <body>
      <h1>Direct WebSocket Test</h1>
      <button onclick="testWS()">Test WebSocket</button>
      <pre id="log"></pre>
      
      <script>
        function log(msg) {
          document.getElementById('log').innerHTML += msg + '\\n';
        }
        
        function testWS() {
          log('Testing WebSocket connection...');
          const ws = new WebSocket('wss://phoenix.biantaishabi.org/live/websocket?vsn=2.0.0');
          
          ws.onopen = () => {
            log('WebSocket opened!');
            // Try Phoenix protocol handshake
            ws.send(JSON.stringify({
              topic: "phoenix",
              event: "heartbeat",
              payload: {},
              ref: "1"
            }));
          };
          
          ws.onmessage = (e) => {
            log('Received: ' + e.data);
          };
          
          ws.onerror = (e) => {
            log('Error: ' + e);
          };
          
          ws.onclose = (e) => {
            log('Closed: code=' + e.code + ', reason=' + e.reason);
          };
        }
      </script>
    </body>
    </html>
    """)
  end
end