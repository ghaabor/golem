defmodule Golem.Adapter.Slack.Socket do
  @moduledoc """
  Handles the Slack RTM socket connection.
  """
  alias Golem.Adapter.Slack
  alias Golem.Command
  alias Golem.CommandRegistry

  require Logger

  def recv!(socket) do
    {type, resp} = socket |> Socket.Web.recv!
    Logger.debug("[#{type}] #{resp}")
    msg = type |> extract_message_for_type(resp)

    socket
    |> handle_message(msg)
    |> recv!
  end

  def text!(socket, message, channel) do
    payload = %{id: 1, type: "message", channel: channel, text: message}
    socket |> Socket.Web.send!({:text, "#{Poison.Encoder.encode(payload, [])}"})
    socket
  end

  def pong!(socket) do
    socket |> Socket.Web.send!({:pong, ""})
    Logger.info("Pong.")
    socket
  end

  defp parse_response(resp) do
    Poison.Parser.parse!(resp)
  end

  defp extract_message_for_type(type, resp) do
    case type do
      :ping ->
        Logger.info("Ping.")
        %{"type" => "ping"}
      :text ->
        resp |> parse_response
      _ ->
        Logger.info("Unhandled type: :#{type}")
        %{}
    end
  end

  defp handle_message(socket, msg) do
    case msg["type"] do
      "ping" ->
        socket |> pong!
      "message" ->
        socket |> find_and_execute_command(msg)
      "reconnect_url" ->
        :ets.insert(:config, {:reconnect_url, msg["url"]})
        Logger.info("New reconnect_url: #{msg["url"]}")
      "presence_change" ->
        [{_id, user}] = :ets.lookup(:users, msg["user"])
        Logger.info("@#{user["name"]} is now #{msg["presence"]}")
      "user_typing" ->
        [{_id, user}] = :ets.lookup(:users, msg["user"])
        [{_id, channel}] = :ets.lookup(:channels, msg["channel"])
        Logger.info("@#{user["name"]} is now typing in #{channel["name"] || user["name"]}")
      "error" ->
        Logger.error("#{msg["error"]["msg"]} (#{msg["error"]["code"]})")
      _ ->
        Logger.info("Unhandled message: [#{msg["type"] || "nil"}] #{msg}")
    end

    socket
  end

  defp find_and_execute_command(socket, msg) do
    command = CommandRegistry.match(msg["text"])
    if command do
      socket |> text!(command.function.(), msg["channel"])
    end
  end
end
