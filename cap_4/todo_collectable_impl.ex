defmodule TodoList.Collectable do
  defimpl Collectable, for: TodoList do
    def into(todo_list) do
      {todo_list, &into_callback/2}
    end

    defp into_callback(todo_list, {:cont, entry}) do
      TodoList.add_entry(todo_list, entry)
    end

    defp into_callback(todo_list, :done) do
      todo_list
    end

    defp into_callback(todo_list, :halt), do: :ok
  end
end
