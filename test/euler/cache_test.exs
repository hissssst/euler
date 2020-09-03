defmodule Euler.CacheTest do

  # Я не создаю отдельную базу в редисе для тестов,
  # потому что просто экономлю своё время

  @keys ~w(a b c d)

  use ExUnit.Case, async: false
  alias Euler.Cache

  setup_all do
    Euler.Application.cache_config()
    |> Cache.start_link()

    on_exit fn ->
      GenServer.stop(Cache)
    end
  end

  setup _context do
    on_exit fn ->
      :ok = Cache.delete(@keys)
    end
    {:ok, %{keys: @keys}}
  end

  test "Simple lazyness test", context do
    Enum.map(context.keys, fn key ->
      {:ok, 1} = Cache.get_lazy(key, fn -> 1 end)
    end)

    # No misses
    Enum.map(context.keys, fn key ->
      {:ok, 1} = Cache.get_lazy(key, fn -> 2 end)
    end)
  end

  @tag timeout: 120_000
  test "Cache expired and created once more", context do
    Enum.map(context.keys, fn key ->
      {:ok, 1} = Cache.get_lazy(key, fn -> 1 end)
    end)

    timeout = Euler.Application.cache_config()[:timeout] || 10
    Process.sleep(1000 * timeout + 100)

    # Misses
    Enum.map(context.keys, fn key ->
      {:ok, 2} = Cache.get_lazy(key, fn -> 2 end)
    end)
  end

end
