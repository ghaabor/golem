defmodule Golem.CommandRegistryTest do
  use ExUnit.Case

  alias Golem.Command
  alias Golem.CommandRegistry

  setup do
    {:ok, _registry} = CommandRegistry.start_link
    c = %Command{regex: ~r/test/, function: fn -> "test" end}

    {:ok, test_command: c}
  end

  test "registry starts empty" do
    assert CommandRegistry.read == []
  end

  test "adds command to registry", %{test_command: test_command} do
    CommandRegistry.add(test_command)

    assert CommandRegistry.read == [test_command]
  end

  test "match finds the command", %{test_command: test_command} do
    CommandRegistry.add(test_command)

    assert CommandRegistry.match("test") == test_command
    assert CommandRegistry.match("this is a longer test message") == test_command
  end
end