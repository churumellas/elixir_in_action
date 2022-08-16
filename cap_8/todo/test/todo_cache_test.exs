defmodule TodoCacheTest do
  use ExUnit.Case

  describe "Testes para cache de server process de todos" do
    test "Todo.Cache.server_process/2" do
      {:ok, cache_pid} = Todo.Cache.start()
      almir_pid = Todo.Cache.server_process(cache_pid, "almir todo list")
      assert almir_pid == Todo.Cache.server_process(cache_pid, "almir todo list")
      assert almir_pid != Todo.Cache.server_process(cache_pid, "neto todo list")
    end
  end
end
