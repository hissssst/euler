defmodule Euler.Cache do

  @moduledoc """
  Redis-based cache module
  """

  import :erlang, only: [term_to_binary: 1, binary_to_term: 1]
  require Logger

  # @type option :: Redix.option() | {:timeout, pos_integer()}
  @type option :: {atom(), any()}
  @type options :: [option()]

  @type key :: String.t()
  @type value :: any()

  @cache_opts_keys [:cache_timeout]

  # Worker callbacks

  @spec start_link(options()) :: GenServer.on_start()
  def start_link(config) do
    {cache_opts, redix_opts} = Keyword.split(config, @cache_opts_keys)

    init_cache_opts(cache_opts)

    redix_opts
    |> Keyword.put(:name, __MODULE__)
    |> Redix.start_link()
  end

  @spec child_spec(options()) :: Supervisor.child_spec()
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  # Public API

  @doc """
  Tries to get value from cache
  otherwise generates value from passed lazy function
  """
  @spec get_lazy(key(), (() -> value())) :: {:ok, value()} | {:error, any()}
  def get_lazy(key, lazy_func) do
    timeout = get_cache_opt(:cache_timeout)
    with {:error, :does_not_exist} <- get_expire(key, timeout) do
      Logger.debug("Cache miss")
      set_expire(key, lazy_func.(), timeout)
    end
  end

  @spec delete(key() | [key()]) :: :ok | {:error, any()}
  def delete([_ | _] = keys) do
    l = length(keys)
    case del(keys) do
      {:ok, ^l} -> :ok
      {:ok, _} -> {:error, :partial}
      other ->
        Logger.error("Failed to delete data from Redis with #{inspect other}")
        other
    end
  end
  def delete(key), do: delete([key])

  # Privates

  @spec set_expire(key(), value(), timeout()) :: {:ok, value()} | {:error, any()}
  defp set_expire(key, value, timeout) do
    Redix.command(conn(), ["SET", key, term_to_binary(value), "EX", "#{timeout}"])
    |> case do
      {:ok, "OK"} ->
        {:ok, value}

      {:ok, _} = x ->
        Logger.error("This should never happen!!! Unexpected result #{inspect x}")
        raise RuntimeError, "Unexpected message"

      other ->
        Logger.error("Failed to write to Redis with #{inspect other}")
        other
    end
  end

  @spec get_expire(key(), timeout()) :: {:ok, value()} | {:error, any()}
  defp get_expire(key, timeout) do
    commands = [
      ["GET", key],
      ["EXPIRE", key, "#{timeout}"]
    ]
    case Redix.transaction_pipeline(conn(), commands) do
      {:ok, [value, 1]} when is_binary(value) ->
        {:ok, binary_to_term(value)}

      {:ok, [nil, 0]} ->
        {:error, :does_not_exist}

      {:ok, _} = x ->
        Logger.error("This should never happen!!! Unexpected result #{inspect x}")
        raise RuntimeError, "Unexpected message"

      other ->
        Logger.error("Failed to read from Redis with #{inspect other}")
        other
    end
  end

  @spec del([key()]) :: {:ok, non_neg_integer()} | {:error, any()}
  defp del(keys) do
    Redix.command(conn(), ["DEL" | keys])
  end

  # Не хочу спавнить отдельный процесс, держащий соединение
  # Поэтому сохраню таймаут в `:persistent_term`
  @spec init_cache_opts(Keyword.t()) :: :ok
  defp init_cache_opts(opts) do
    Enum.each(opts, fn {k, v} -> :persistent_term.put({__MODULE__, k}, v) end)
  end

  @spec get_cache_opt(atom(), any()) :: any()
  defp get_cache_opt(opt_name, default \\ nil) do
    :persistent_term.get({__MODULE__, opt_name}, default)
  end

  # Можно переопределить на случай пулла
  @spec conn() :: Redix.connection()
  defp conn do
    __MODULE__
  end

end
