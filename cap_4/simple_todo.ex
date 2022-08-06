defmodule TodoList do
  alias MultiDict
  def new, do: %{}

  def add_entry(todo_list, entry) do
    MultiDict.add(todo_list, entry.data, entry)
  end

  def entries(todo_list, date) do
    MultiDict.get(todo_list, date)
  end
end
