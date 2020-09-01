# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :euler,
  ecto_repos: [Euler.Repo]

# Configures the endpoint
config :euler, EulerWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "kNVJ0moIh+xZh2tcR/Fm/4cG2Ab0+zTuFC9wUhL+/P2E5Ay0mmUpbvcyrvhsWtlu",
  render_errors: [view: EulerWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Euler.PubSub,
  live_view: [signing_salt: "vUqcIJYh"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
