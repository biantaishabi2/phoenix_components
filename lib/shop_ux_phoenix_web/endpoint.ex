defmodule ShopUxPhoenixWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :shop_ux_phoenix

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_shop_ux_phoenix_key",
    signing_salt: "sMCZbqGS",
    same_site: "Lax"
  ]

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options, x_headers: ["x-forwarded-for", "x-forwarded-proto", "x-forwarded-port"]]],
    longpoll: [connect_info: [session: @session_options]]
  
  # 为不同路径添加 socket，确保 nginx 路由的请求能被正确处理
  for path <- ~w(components demo debug simple_debug test_ws minimal ws_test docs) do
    socket "/#{path}/live", Phoenix.LiveView.Socket,
      websocket: [connect_info: [session: @session_options, x_headers: ["x-forwarded-for", "x-forwarded-proto", "x-forwarded-port"]]],
      longpoll: [connect_info: [session: @session_options]]
  end
  
  # 为 showcase 添加专门的 socket 路径
  socket "/components/showcase/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options, x_headers: ["x-forwarded-for", "x-forwarded-proto", "x-forwarded-port"]]],
    longpoll: [connect_info: [session: @session_options]]
  
  # 为 petal 添加专门的 socket 路径
  socket "/components/petal/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options, x_headers: ["x-forwarded-for", "x-forwarded-proto", "x-forwarded-port"]]],
    longpoll: [connect_info: [session: @session_options]]
  
  # 为 demo/petal 添加专门的 socket 路径
  socket "/demo/petal/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options, x_headers: ["x-forwarded-for", "x-forwarded-proto", "x-forwarded-port"]]],
    longpoll: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :shop_ux_phoenix,
    gzip: false,
    only: ShopUxPhoenixWeb.static_paths()

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug ShopUxPhoenixWeb.Router
end
