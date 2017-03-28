defmodule Golem.CommandRegistry do
  @moduledoc """
  The command registry for the bot. Implemented using GenServer.
  """

  use GenServer
  require Logger

  # Client API

  @doc """
  Starts CommandRegistry.

  Returns `{:ok, pid}`.

  ## Examples

      iex> Golem.CommandRegistry.start_link
      {:ok, #PID<0.87.0>}

  """
  def start_link, do: GenServer.start_link(__MODULE__, :ok, name: __MODULE__)

  def read, do: GenServer.call(__MODULE__, {:read})

  def add(command), do: GenServer.cast(__MODULE__, {:add, command})

  def match(message), do: GenServer.call(__MODULE__, {:match, message})

  # Server API
  def init(:ok) do
    {:ok, []}
  end

  def handle_call({:read}, _from, commands) do
    {:reply, commands, commands}
  end

  def handle_call({:match, message}, _from, commands) do
    {:reply, match(message, commands), commands}
  end

  def handle_cast({:add, item}, commands) do
    {:noreply, commands ++ [item]}
  end

  defp match(_, []), do: nil
  defp match(message, [head|tail]) do
    if String.match?(message, head.regex) do
      head
    else
      match(message, tail)
    end
  end
end
