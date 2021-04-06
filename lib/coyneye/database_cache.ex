defmodule Coyneye.DatabaseCache do
  use GenServer

  def start_link(_default) do
    GenServer.start_link(__MODULE__, %{}, name: CoyneyeDatabaseCache)
  end

  def init(state) do
    :ets.new(:currency_cache, [:set, :public, :named_table])

    {:ok, state}
  end

  def get(key), do: GenServer.call(CoyneyeDatabaseCache, {:get, key})

  def put(key, data), do: GenServer.cast(CoyneyeDatabaseCache, {:put, key, data})

  def delete(key), do: GenServer.cast(CoyneyeDatabaseCache, {:delete, key})

  # GenServer API
  #
  def handle_call({:get, key}, _from, state) do
    reply =
      case :ets.lookup(:currency_cache, key) do
        [] -> nil
        [{_key, currency}] -> currency
      end

    {:reply, reply, state}
  end

  def handle_cast({:put, key, data}, state) do
    :ets.insert(:currency_cache, {key, data})

    {:noreply, state}
  end

  def handle_cast({:delete, key}, state) do
    :ets.delete(:currency_cache, key)

    {:noreply, state}
  end
end
