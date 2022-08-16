defmodule Todo.Database do
  use GenServer
  require Logger
  alias Todo.DatabaseWorker

  @db_foler "./persist"

  def start do
    Logger.debug("Iniciando processo Database.")
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  def save(key, data) do
    GenServer.cast(__MODULE__, {:save, key, data})
  end

  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  @impl GenServer
  def init(_) do
    File.mkdir_p!(@db_foler)

    workers =
      0..2
      |> Enum.map(fn _ -> GenServer.start(DatabaseWorker, @db_foler) end)
      |> Enum.map(fn {:ok, pid} -> pid end)
      |> Enum.with_index()
      |> Enum.map(fn {k, v} -> {v, k} end)
      |> Enum.into(%{})

    {:ok, workers}
  end

  @impl GenServer
  def handle_call({:get, key}, caller, state) do
    :erlang.phash2(key, 3)
    |> then(&Map.get(state, &1))
    |> DatabaseWorker.get(key, caller)

    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:save, key, data}, state) do
    :erlang.phash2(key, 3)
    |> then(&Map.get(state, &1))
    |> DatabaseWorker.store(key, data)

    {:noreply, state}
  end
end
