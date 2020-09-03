defmodule EulerWeb.PageLive do

  @moduledoc """
  "/" path LiveView page
  """

  use EulerWeb, :live_view

  alias Phoenix.PubSub

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    :ok = PubSub.subscribe(Euler.PubSub, "clients")
    verifications =
      Euler.latest(20)
      |> Enum.map(&Map.from_struct/1)
    socket = assign(socket, verifications: verifications)
    {:ok, socket, temporary_assigns: [verifications: []]}
  end

  @impl true
  def handle_event("inn_verification", %{"inn_input" => input}, socket) do
    case Euler.verify(input) do
      {:ok, verification} ->
        verification
        |> Map.from_struct()
        |> notify_clients()

      {:error, reason} ->
        Logger.error("Failed to write verification with #{inspect reason.errors}")
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info({:new_verification, verification}, socket) do
    {:noreply, assign(socket, verifications: [verification])}
  end

  @spec notify_clients(any()) :: :ok
  defp notify_clients(verification) do
    :ok = PubSub.broadcast(Euler.PubSub, "clients", {:new_verification, verification})
  end

end
