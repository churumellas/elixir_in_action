defmodule Todo.Server do
  use Agent, restart: :temporary
  require Logger

  alias Todo.List, as: TodoList

  def start_link(server_name) do
    Agent.start(
      fn ->
        Logger.debug("Iniciando Todo Server para #{server_name}")
        {server_name, Todo.Database.get(server_name) || TodoList.new(server_name)}
      end,
      name: via_tuple(server_name)
    )
  end

  def add_entry(server_pid, entry) do
    Agent.cast(
      server_pid,
      fn {server_name, todo_list} ->
        new_list = TodoList.add_entry(todo_list, entry)
        Todo.Database.save(new_list.name, new_list)
        {server_name, new_list}
      end
    )
  end

  def remove_entry(server_pid, id) do
    Agent.cast(server_pid, fn {server_name, todo_list} ->
      new_list = TodoList.delete_entry(todo_list, id)
      Todo.Database.save(new_list.name, new_list)
      {server_name, new_list}
    end)
  end

  def list_entries(server_pid, date) do
    Agent.get(server_pid, fn {_server_name, todo_list} ->
      TodoList.entries(todo_list, date)
    end)
  end

  defp via_tuple(server_name) do
    Todo.ProcessRegistry.via_tuple({__MODULE__, server_name})
  end
end
