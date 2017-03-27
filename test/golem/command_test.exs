defmodule Golem.CommandTest do
  use ExUnit.Case

  alias Golem.Command
  alias Golem.CommandRegistry

  setup do
    {:ok, _registry} = CommandRegistry.start_link
    r = ~r/test/
    f = fn -> "test" end
    {:ok, %{test_regex: r, test_fun: f}}
  end

  test "adds a command", %{test_regex: test_regex, test_fun: test_fun} do
    Command.command(test_regex, test_fun)

    reg = CommandRegistry.read
    assert Enum.count(reg) == 1
    
    [c|_] = reg
    assert c.regex == test_regex
    assert c.function == test_fun
  end
end