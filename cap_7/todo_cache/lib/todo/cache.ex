defmodule Todo.Cache do
  use GenServer
  alias Todo.Server

  def start do
    GenServer.start(__MODULE__, nil)
  end

  def server_process(cache_pid, todo_server_name) do
    GenServer.call(cache_pid, {:server_process, todo_server_name})
  end

  def init(_) do
    Todo.Database.start()
    {:ok, %{}}
  end

  def handle_call({:server_process, todo_server_name}, _caller, todo_server_pool) do
    case Map.fetch(todo_server_pool, todo_server_name) do
      {:ok, server_pid} ->
        {:reply, server_pid, todo_server_pool}

      :error ->
        {:ok, new_server} = Server.start(todo_server_name)
        {:reply, new_server, Map.put(todo_server_pool, todo_server_name, new_server)}
    end
  end
end
