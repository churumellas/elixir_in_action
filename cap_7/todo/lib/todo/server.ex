defmodule Todo.Server do
  alias Todo.List, as: TodoList
  use GenServer

  def start do
    {:ok, pid} = GenServer.start(Todo.Server, nil)
    Process.register(pid, TodoServer)
  end

  def add_entry(entry) do
    GenServer.cast(Todo.Server, {:add_entry, entry})
  end

  def remove_entry(id) do
    GenServer.cast(Todo.Server, {:remove_entry, id})
  end

  def list_entries(date) do
    GenServer.call(Todo.Server, {:list, date})
  end

  # GenServer callback implementations
  @impl GenServer
  def init(_) do
    {:ok, TodoList.new()}
  end

  @impl GenServer
  def handle_cast({:add_entry, entry}, todo_list) do
    {:noreply, TodoList.add_entry(todo_list, entry)}
  end

  @impl GenServer
  def handle_cast({:remove_entry, id}, todo_list) do
    {:noreply, TodoList.delete_entry(todo_list, id)}
  end

  @impl GenServer
  def handle_call({:list, date}, _caller, todo_list) do
    {:reply, TodoList.entries(todo_list, date), todo_list}
  end
end
