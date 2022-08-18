defmodule Todo.DatabaseWorker do
  use GenServer
  require Logger

  def start_link({database_folder, worker_id}) do
    Logger.debug("Iniciando DatabaseWorker #{worker_id}.")

    GenServer.start_link(
      __MODULE__,
      database_folder,
      name: via_tuple(worker_id)
    )
  end

  def store(worker_pid, key, data) do
    GenServer.cast(via_tuple(worker_pid), {:store, key, data})
  end

  def get(worker_pid, key) do
    GenServer.call(via_tuple(worker_pid), {:get, key})
  end

  @impl GenServer
  def init(database_folder) do
    {:ok, database_folder}
  end

  @impl GenServer
  def handle_call({:get, key}, _caller, database_folder) do
    key
    |> file_name(database_folder)
    |> File.read()
    |> bump_data_term()
    |> then(fn data -> {:reply, data, database_folder} end)
  end

  @impl GenServer
  def handle_cast({:store, key, data}, database_folder) do
    key
    |> file_name(database_folder)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, database_folder}
  end

  defp file_name(key, database_folder) do
    Path.join(database_folder, key)
  end

  defp bump_data_term({:ok, content}), do: :erlang.binary_to_term(content)
  defp bump_data_term(_), do: nil

  defp via_tuple(worker_id) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, worker_id})
  end
end
