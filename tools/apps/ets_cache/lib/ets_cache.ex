defmodule EtsCache.Cache do
  use GenServer
  require Logger

  def start_link() do
     GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    generate_table()
    {:ok, %{}}
  end

  def set(key, val) do
    GenServer.call(__MODULE__, {:set, key, val})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def clear do
    GenServer.call(__MODULE__, :clear)
  end

  def handle_call({:get, key}, _from, state) do
    case :ets.lookup(:ets_cache, key) do
      [{^key, value} | _rest] -> {:reply, value, state}
      [] -> {:reply, :not_found, state}
    end
  end

  def handle_call({:set, key, val}, _from, state) do
    # insert the value into the table
    case :ets.insert(:ets_cache, {key, val}) do
      true -> {:reply, val, state}
      _ -> {:reply, :error, state}
    end
  end

  def handle_call({:clear}, _from, _state) do
    # insert the value into the table
    :ets.delete(:ets_cache)
    generate_table()
    {:noreply}
  end

  defp generate_table() do
    :ets.new(:ets_cache, [:named_table, :set, :protected])
  end
end
