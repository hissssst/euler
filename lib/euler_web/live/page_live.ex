defmodule EulerWeb.PageLive do

  @moduledoc """
  "/" path LiveView page
  """

  use EulerWeb, :live_view

  alias Euler.INNVerification
  alias Phoenix.PubSub

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    :ok = PubSub.subscribe(Euler.PubSub, "clients")
    verifications =
      INNVerification.latest(20)
      |> Enum.map(&Map.from_struct/1)
    socket = assign(socket, verifications: verifications)
    {:ok, socket, temporary_assigns: [verifications: []]}
  end

  @impl true
  def handle_event("inn_verification", %{"inn_input" => input}, socket) do
    case INNVerification.verify(input) do
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
    socket =
      socket
      |> assign(verifications: [verification])

    {:noreply, socket}
  end

  @spec notify_clients(any()) :: :ok
  defp notify_clients(verification) do
    :ok = PubSub.broadcast(Euler.PubSub, "clients", {:new_verification, verification})
  end

end
