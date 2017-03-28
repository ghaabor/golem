defmodule Golem do
  @moduledoc """
  The entry point for the Golem.
  """
  alias Golem.CommandRegistry
  alias Golem.ExampleCommands
  use Application

  defmacro __using__ do
    quote do
      import Golem
      unquote(Application.fetch_env!(:golem, :adapter)).connect()
    end
  end

  def start(_type, _args) do
    {:ok, _registrty_pid} = CommandRegistry.start_link

    ExampleCommands.Test.init

    {:ok, _pid} = Application.fetch_env!(:golem, :adapter).connect()
  end
end
