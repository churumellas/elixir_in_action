defmodule Todo.Database do
  use GenServer

  @db_foler "./persist"

  def start do
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
    {:ok, nil}
  end

  @impl GenServer
  def handle_call({:get, key}, caller, state) do
    spawn(fn ->
      key
      |> file_name()
      |> File.read()
      |> bump_data_term()
      |> then(fn data -> GenServer.reply(caller, data) end)
    end)

    {:noreply, state}
  end

  @impl GenServer
  def handle_cast({:save, key, data}, state) do
    spawn(fn ->
      key
      |> file_name()
      |> File.write!(:erlang.term_to_binary(data))
    end)

    {:noreply, state}
  end

  defp file_name(key), do: Path.join(@db_foler, key)

  defp bump_data_term({:ok, content}), do: :erlang.binary_to_term(content)
  defp bump_data_term(_), do: nil
end
