defmodule Todo.List do
  # TODO: criar TodoEntry struct parar garantir que todas entries serão do mesmo tipo
  defstruct name: nil, auto_id: 1, entries: %{}

  def new(server_name, entries \\ []) do
    Enum.reduce(
      entries,
      %Todo.List{name: server_name},
      fn entry, todo_list ->
        add_entry(todo_list, entry)
      end
    )
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.auto_id)

    new_entries =
      Map.put(
        todo_list.entries,
        todo_list.auto_id,
        entry
      )

    %Todo.List{todo_list | auto_id: todo_list.auto_id + 1, entries: new_entries}
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def update_entry(todo_list, entry_id, update_fun) do
    case Map.fetch(todo_list, entry_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        old_entry_id = old_entry.id
        new_entry = %{id: ^old_entry_id} = update_fun.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %{todo_list | entries: new_entries}
    end
  end

  def update_entry(todo_list, %{} = new_entry) do
    update_entry(todo_list, new_entry.id, fn _ -> new_entry end)
  end

  def delete_entry(todo_list, entry_id) do
    todo_list
    |> Map.update!(:entries, &Map.delete(&1, entry_id))
  end

  def from_csv(file_path) do
    file_path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.replace(&1, "/", "-"))
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(fn [date, title] -> %{date: Date.from_iso8601!(date), title: title} end)
    |> then(&new(file_path, &1))
  end
end
