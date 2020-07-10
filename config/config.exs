# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :modal_example,
  ecto_repos: [ModalExample.Repo]

# Configures the endpoint
config :modal_example, ModalExampleWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "RUYi1FA97SVWkCIyNs9Td+2ODa1lmoY8HUq63rXErZEzrFY/qo4HhLQjAboUa2I5",
  render_errors: [view: ModalExampleWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ModalExample.PubSub,
  live_view: [signing_salt: "QzOjVYNI"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
