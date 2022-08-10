defmodule DataBaseServer do
  def start do
    spawn(&loop/0)
  end

  defp loop do
    receive do
      {:run_query, caller, query} ->
        send(caller, {:query_result, run_query(caller, query)})
    end

    loop()
  end

  defp run_query(caller, query) do
    Process.sleep(2000)
    "Finish query: #{query}."
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
