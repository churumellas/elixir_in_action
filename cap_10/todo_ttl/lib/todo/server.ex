defmodule Todo.Server do
  @ttl :timer.minutes(5)

  use GenServer, restart: :temporary
  require Logger

  alias Todo.List, as: TodoList

  def start_link(server_name) do
    GenServer.start_link(__MODULE__, server_name, name: via_tuple(server_name))
  end

  def add_entry(server_pid, entry) do
    GenServer.cast(server_pid, {:add_entry, entry})
  end

  def remove_entry(server_pid, id) do
    GenServer.cast(server_pid, {:remove_entry, id})
  end

  def list_entries(server_pid, date) do
    GenServer.call(server_pid, {:list, date})
  end

  defp via_tuple(server_name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, server_name})
  end

  # GenServer callback implementations
  @impl GenServer
  def init(server_name) do
    Logger.debug("Iniciando um Server para #{server_name}.")

    {
      :ok,
      Todo.Database.get(server_name) || TodoList.new(server_name),
      @ttl
    }
  end

  @impl GenServer
  def handle_cast({:add_entry, entry}, todo_list) do
    new_list = TodoList.add_entry(todo_list, entry)
    Todo.Database.save(new_list.name, new_list)
    {:noreply, new_list, @ttl}
  end

  @impl GenServer
  def handle_cast({:remove_entry, id}, todo_list) do
    new_list = TodoList.delete_entry(todo_list, id)
    Todo.Database.save(new_list.name, new_list)
    {:noreply, new_list, @ttl}
  end

  @impl GenServer
  def handle_call({:list, date}, _caller, todo_list) do
    {
      :reply,
      TodoList.entries(todo_list, date),
      todo_list,
      @ttl
    }
  end

  @impl GenServer
  def handle_info(:timeout, todo_list) do
    Logger.debug("Tempo expirado para servidor #{todo_list.name}.")
    {:stop, :normal, todo_list}
  end
end
