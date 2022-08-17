defmodule Todo.Database do
  require Logger
  alias Todo.DatabaseWorker

  @db_foler "./persist"
  @pool_size 5

  def start_link do
    Logger.debug("Iniciando processo Database.")
    File.mkdir_p!(@db_foler)

    childs = Enum.map(1..@pool_size, &worker_spec/1)

    Supervisor.start_link(childs, strategy: :one_for_one)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  def save(key, data) do
    key
    |> choose_worker()
    |> DatabaseWorker.store(key, data)
  end

  def get(key) do
    key
    |> choose_worker()
    |> DatabaseWorker.get(key)
  end

  defp choose_worker(key) do
    :erlang.phash2(key, @pool_size) + 1
  end

  defp worker_spec(worker_id) do
    Supervisor.child_spec(
      DatabaseWorker,
      id: worker_id,
      start: {DatabaseWorker, :start_link, [{@db_foler, worker_id}]}
    )
  end
end
