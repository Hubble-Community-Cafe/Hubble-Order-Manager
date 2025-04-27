import Config
import Dotenvy
# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/hubble_order_manager start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.


source!([
  Path.absname(".env"),
  System.get_env()
])

aurora_url =
  env!("AURORA_URL") ||
    raise """
    environment variable AURORA_URL is missing.
    For example: https://aurora.example.com
    """
aurora_api_key =
  env!("AURORA_API_KEY") ||
    raise """
    environment variable AURORA_KEY is missing.
    """

config :hubble_order_manager, :aurora,
  aurora_url: aurora_url,
  aurora_api_key: aurora_api_key

webhook_public_key_url =
  env!("WEBHOOK_PUBLIC_KEY_URL") ||
    raise """
    environment variable WEBHOOK_PUBLIC_KEY_URL is missing.
    For example: https://api.starcommunity.app/.well-known/webhooks.key
    """

config :hubble_order_manager, :webhook,
  webhook_public_key_url: webhook_public_key_url

login_token =
  env!("LOGIN_TOKEN") ||
    raise """
    environment variable LOGIN_TOKEN is missing.
    For example: 1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
    """
config :hubble_order_manager, :auth,
  login_token: login_token

order_timeout =
  env!("ORDER_TIMEOUT") ||
    raise """
    environment variable ORDER_TIMEOUT is missing.
    For example: 300
    """
config :hubble_order_manager, :order,
  order_timeout: String.to_integer(order_timeout)

if System.get_env("PHX_SERVER") do
  config :hubble_order_manager, HubbleOrderManagerWeb.Endpoint, server: true
end

if config_env() == :prod do
  database_path =
    System.get_env("DATABASE_PATH") ||
      raise """
      environment variable DATABASE_PATH is missing.
      For example: /etc/hubble_order_manager/hubble_order_manager.db
      """

  config :hubble_order_manager, HubbleOrderManager.Repo,
    database: database_path,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "5")

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :hubble_order_manager, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :hubble_order_manager, HubbleOrderManagerWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://hexdocs.pm/bandit/Bandit.html#t:options/0
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base
end
