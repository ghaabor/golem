defmodule Golem.Adapter.Slack.Socket do
  alias Golem.Adapter.Slack
  alias Golem.Command
  alias Golem.CommandRegistry

  require Logger

  def recv!(socket) do
    {type, resp} = socket |> Socket.Web.recv!
    Logger.debug("[#{type}] #{resp}")
    msg =
      case type do
        :ping -> 
          Logger.info("Ping.")
          socket |> pong!
          nil
        :text -> 
          resp |> parse_response 
        _ -> 
          Logger.info("Unhandled type: #{type}")
          nil
      end

    if msg do
      case msg["type"] do
        "message" ->
          command = CommandRegistry.match(msg["text"])
          if command do
            socket |> text!(command.function.(), msg["channel"])
          end
        "reconnect_url" ->
          :ets.insert(:config, {:reconnect_url, msg["url"]})
          Logger.info("New reconnect_url: #{msg["url"]}")
        "presence_change" ->
          [{_id, user}] = :ets.lookup(:users, msg["user"])
          Logger.info("@#{user["name"]} is now #{msg["presence"]}")
        "error" ->
          Logger.error("#{msg["error"]["msg"]} (#{msg["error"]["code"]})")
        _ -> Logger.info("Unhandled message: [#{type}] #{resp}")
      end
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
  end

  defp parse_response(resp) do
    Poison.Parser.parse!(resp)
  end
end