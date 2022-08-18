defmodule Todo.Cache do
  require Logger

  alias Todo.Server

  def start_link do
    Logger.debug("Iniciando processo Cache")
    DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)
  end

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, []},
      type: :supervisor
    }
  end

  def server_process(todo_server_name) do
    case start_child(todo_server_name) do
      {:ok, server_pid} -> server_pid
      {:error, {:already_started, server_pid}} -> server_pid
    end
  end

  defp start_child(server_name) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {Server, server_name}
    )
  end
end
