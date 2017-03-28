defmodule Golem.Command do
  @moduledoc """
  Abstract command module to use in actual commands.
  """
  alias Golem.Command
  alias Golem.CommandRegistry

  defmacro __using__(_opts) do
    quote do
      import Golem.Command
    end
  end

  @enforce_keys [:regex, :function]
  defstruct [:regex, :function]

  def command(regex, function) do
    c = %Command{regex: regex, function: function}
    CommandRegistry.add(c)
  end
end
