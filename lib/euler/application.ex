defmodule Euler.Application do

  @moduledoc """
  Main application module
  """

  use Application

  @default_cache_options [
    host: "localhost",
    timeout: 10
  ]

  def start(_type, _args) do
    children = [
      Euler.Repo,
      EulerWeb.Telemetry,
      {Phoenix.PubSub, name: Euler.PubSub},
      EulerWeb.Endpoint,

      {Euler.Cache, cache_config()}
    ]

    opts = [strategy: :one_for_one, name: Euler.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    EulerWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def cache_config() do
    Application.get_env(:euler, Euler.Cache, @default_cache_options)
  end

end
