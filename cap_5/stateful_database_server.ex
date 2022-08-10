defmodule DataBaseServer do
  def start do
    initial_state = :random.uniform() - 1
    spawn(fn -> loop(initial_state) end)
  end

  defp loop(state) do
    receive do
      {:run_query, caller, query} ->
        send(caller, {:query_result, run_query(caller, query, state)})
    end

    loop(state)
  end

  defp run_query(caller, query, connection) do
    Process.sleep(2000)
    "Finish query(#{connection}): #{query}."
  end

  def run_async(server_pid, query) do
    send(server_pid, {:run_query, self(), query})
  end

  def get_result do
    receive do
      {:query_result, result} -> result
    after
      5000 -> {:error, :timeout}
    end
  end
end
