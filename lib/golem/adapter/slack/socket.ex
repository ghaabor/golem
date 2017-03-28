defmodule Golem.Adapter.Slack.Socket do
  @moduledoc """
  Handles the Slack RTM socket connection.
  """
  alias Golem.CommandRegistry

  require Logger

  def recv!(socket) do
    {type, resp} = socket |> Socket.Web.recv!
    Logger.debug("[#{type}] #{resp}")
    msg = type |> extract_message_for_type(resp)

    socket
    |> handle_message!(msg)
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

  defp handle_message!(socket, msg) do
    handle_message_with_type(socket, msg["type"], msg)
    socket
  end

  defp handle_message_with_type(socket, type, _msg) when type == "ping" do
    socket |> pong!
  end

  defp handle_message_with_type(socket, type, msg) when type == "message" do
    socket |> find_and_execute_command(msg)
  end

  defp handle_message_with_type(_socket, type, msg) when type == "reconnect_url" do
    :ets.insert(:config, {:reconnect_url, msg["url"]})
    Logger.info("New reconnect_url: #{msg["url"]}")
  end

  defp handle_message_with_type(_socket, type, msg) when type == "presence_change" do
    [{_id, user}] = :ets.lookup(:users, msg["user"])
    Logger.info("@#{user["name"]} is now #{msg["presence"]}")
  end

  defp handle_message_with_type(_socket, type, msg) when type == "user_typing" do
    [{_id, user}] = :ets.lookup(:users, msg["user"])
    [{_id, channel}] = :ets.lookup(:channels, msg["channel"])
    Logger.info("@#{user["name"]} is now typing in #{channel["name"] || user["name"]}")
  end

  defp handle_message_with_type(_socket, type, msg) when type == "error" do
    Logger.error("#{msg["error"]["msg"]} (#{msg["error"]["code"]})")
  end

  defp handle_message_with_type(_socket, type, msg) do
    Logger.info("Unhandled message: [#{type || "nil"}] #{Poison.encode!(msg)}")
  end

  defp find_and_execute_command(socket, msg) do
    command = CommandRegistry.match(msg["text"])
    if command do
      socket |> text!(command.function.(), msg["channel"])
    end
  end
end
