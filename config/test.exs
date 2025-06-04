import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :shop_ux_phoenix, ShopUxPhoenixWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "ek6QAYGLFC1n42UHNFO79B/taDYkNX39tOa9YJCTeRvZ1uvbfwlkggLNboaV/LzU",
  server: false

# In test we don't send emails
config :shop_ux_phoenix, ShopUxPhoenix.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
