defmodule KeyValueServer do
  use GenServer

  def put(pid, key, value) do
    GenServer.cast(pid, {:put, key, value})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  # Genserver callback implementations
  def init(%{} = initial_state) do
    {:ok, initial_state}
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_cast({:put, key, value}, state) do
    {:noreply, Map.put(state, key, value)}
  end

  def handle_call({:get, key}, _caller, state) do
    {:reply, Map.get(state, key), state}
  end
end
