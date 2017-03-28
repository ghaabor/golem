defmodule Golem do
  @moduledoc """
  The entry point for the Golem.
  """
  alias Golem.CommandRegistry

  require Logger

  defmacro __using__ do
    quote do
      require Golem
    end
  end

  def start(commands) do
    {:ok, _registrty_pid} = CommandRegistry.start_link

    # Init all the commands the user specified.
    commands |> Enum.each(&init_commands/1)

    {:ok, _pid} = :erlang.apply(Application.fetch_env!(:golem, :adapter), :connect, [])
  end

  defp init_commands(command) do
    :erlang.apply(command, :init, [])
  end
end
