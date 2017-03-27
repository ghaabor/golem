defmodule Golem do
  use Application

  defmacro __using__ do
    quote do
      import Golem
      unquote(Application.fetch_env!(:golem, :adapter)).connect()
    end
  end

  def start(_type, _args) do
    {:ok, _registrty_pid} = Golem.CommandRegistry.start_link

    Golem.ExampleCommands.Test.init
    
    {:ok, _pid} = Application.fetch_env!(:golem, :adapter).connect()
  end
end
