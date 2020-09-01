defmodule Euler.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Euler.Repo,
      EulerWeb.Telemetry,
      {Phoenix.PubSub, name: Euler.PubSub},
      EulerWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Euler.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    EulerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
