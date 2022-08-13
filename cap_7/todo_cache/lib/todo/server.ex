defmodule Todo.Server do
  alias Todo.List, as: TodoList
  use GenServer

  def start do
    GenServer.start(__MODULE__, nil)
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
