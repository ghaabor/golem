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

    if msg == :ping, do: socket |> pong! |> recv!

    case msg["type"] do
      "message" ->
        command = CommandRegistry.match(msg["text"])
        if command do
          socket |> text!(command.function.(), msg["channel"]) |> recv!
        end
      "reconnect_url" ->
        :ets.insert(:config, {:reconnect_url, msg["url"]})
        Logger.info("New reconnect_url: #{msg["url"]}")
      "presence_change" ->
        [{_id, user}] = :ets.lookup(:users, msg["user"])
        Logger.info("@#{user["name"]} is now #{msg["presence"]}")
      "error" ->
        Logger.error("#{msg["error"]["msg"]} (#{msg["error"]["code"]})")
      _ ->
        Logger.info("Unhandled message: [#{type or "nil"}] #{resp}")
    end

    socket |> recv!
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
        :ping
      :text ->
        resp |> parse_response
      _ ->
        Logger.info("Unhandled type: #{type}")
        nil
    end
  end
end
