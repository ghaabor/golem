defmodule Golem.ExampleCommands.Test do
  @moduledoc """
  Example commands.
  """
  use Golem.Command

  def init do
    command ~r/test/, fn -> "hello" end
    command ~r/ping/, fn -> "pong" end
  end
end
