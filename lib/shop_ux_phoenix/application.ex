defmodule ShopUxPhoenix.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ShopUxPhoenixWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:shop_ux_phoenix, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ShopUxPhoenix.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ShopUxPhoenix.Finch},
      # Start the form storage for auto-save functionality
      ShopUxPhoenixWeb.FormStorage,
      # Start a worker by calling: ShopUxPhoenix.Worker.start_link(arg)
      # {ShopUxPhoenix.Worker, arg},
      # Start to serve requests, typically the last entry
      ShopUxPhoenixWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ShopUxPhoenix.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ShopUxPhoenixWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
