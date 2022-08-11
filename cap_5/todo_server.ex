defmodule TodoServer do
  def start do
    pid = spawn(fn -> loop(TodoList.new()) end)
    Process.register(pid, TodoServer)
  end

  def loop(todo_list) do
    todo_list =
      receive do
        message -> process_message(todo_list, message)
      end

    loop(todo_list)
  end

  def add_entry(entry) do
    send(TodoServer, {:add_entry, entry})
  end

  def remove_entry(id) do
    send(TodoServer, {:add_entry, id})
  end

  def list_entries(date) do
    send(TodoServer, {:list, self(), date})

    receive do
      {:todo_entries, entries} -> entries
    after
      5000 -> {:error, :timeout}
    end
  end

  defp process_message(todo_list, {:add_entry, entry}) do
    todo_list
    |> TodoList.add_entry(entry)
  end

  defp process_message(todo_list, {:remove_entry, id}) do
    todo_list
    |> TodoList.delete_entry(id)
  end

  defp process_message(todo_list, {:list, caller, date}) do
    send(caller, {:todo_entries, TodoList.entries(todo_list, date)})
    todo_list
  end
end

defmodule TodoList do
  # TODO: criar TodoEntry struct parar garantir que todas entries serão do mesmo tipo
  defstruct auto_id: 1, entries: %{}

  def new, do: %TodoList{}

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
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

    %TodoList{todo_list | auto_id: todo_list.auto_id + 1, entries: new_entries}
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
    Map.delete(
      todo_list,
      entry_id
    )
  end

  def from_csv(file_path) do
    file_path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.replace(&1, "/", "-"))
    |> Stream.map(&String.split(&1, ","))
    |> Stream.map(fn [date, title] -> %{date: Date.from_iso8601!(date), title: title} end)
    |> new()
  end
end
