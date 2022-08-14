defmodule Todo.DatabaseWorker do
  use GenServer

  def store(worker_pid, key, data) do
    GenServer.cast(worker_pid, {:store, key, data})
  end

  def get(worker_pid, key, caller) do
    GenServer.cast(worker_pid, {:get, key, caller})
  end

  @impl GenServer
  def init(database_folder) do
    {:ok, database_folder}
  end

  @impl GenServer
  def handle_cast({:get, key, caller}, database_folder) do
    key
    |> file_name(database_folder)
    |> File.read()
    |> bump_data_term()
    |> then(fn data -> GenServer.reply(caller, data) end)

    {:noreply, database_folder}
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
end
