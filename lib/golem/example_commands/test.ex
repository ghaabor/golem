defmodule Golem.ExampleCommands.Test do
  use Golem.Command

  def init do
    command ~r/test/, fn -> "hello" end
    command ~r/ping/, fn -> "pong" end
  end
end