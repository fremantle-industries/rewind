## This file is responsible for configuring your application
## and its dependencies with the aid of the Mix.Config module.
##
## This configuration file is loaded before any dependency and
## is restricted to this project.

## General application configuration
#use Mix.Config

## Configures the endpoint
#config :rewind, RewindWeb.Endpoint,
#  url: [host: "localhost"],
#  secret_key_base: "uIsXcCsXXptrAhMspslwWysO4zXUvMTannSJy6moML7in7349Ly7Xw5Rkxx/I2dN",
#  render_errors: [view: RewindWeb.ErrorView, accepts: ~w(html json), layout: false],
#  pubsub_server: Rewind.PubSub,
#  live_view: [signing_salt: "YCe1E2To"]

import Config

# Ecto repos must be set at compile time
config :rewind,
  ecto_repos: [
    Rewind.Repo,
    History.Repo,
    Workbench.Repo,
    Tai.Orders.OrderRepo
  ]

# tai can't switch adapters at runtime
config :tai, order_repo_adapter: Ecto.Adapters.Postgres

config :phoenix, :json_library, Jason

# Sets the default runtime to ElixirStandalone.
# This is the desired default most of the time,
# but in some specific use cases you may want
# to configure that to the Embedded or Mix runtime instead.
# Also make sure the configured runtime has
# a synchronous `init` function that takes the
# configured arguments.
# config :livebook, :default_runtime, {Livebook.Runtime.ElixirStandalone, []}
